require 'rails_helper'
require "frequent_apple"


shared_examples "no change" do
  it "does not change running node's bag" do
    subject()
    response = @running_node_client.get("/bag/#{@bag.uuid}")
    expect(response.ok?).to be true
    bag = JSON.parse(response.body, symbolize_names: true)
    expect(bag).to match_without_timestamps(ApiV1::BagPresenter.new(@bag).to_hash)
  end
end

shared_examples "change" do
  it "updates the bag" do
    subject()
    response = @running_node_client.get("/bag/#{@bag.uuid}")
    expect(response.ok?).to be true
    bag = JSON.parse(response.body, symbolize_names: true)
    expect(bag).to match_without_timestamps(@changed_bag_body)
  end
end

describe FrequentApple::SyncBagsJob, type: :integration do
  before(:all) do
    @all_namespaces = Node.all.collect { |n| n.namespace }
  end
  before(:each) do
    `bundle exec cap development rrake:all`
    `rake db:clear`
    `rake db:fixtures:load`
    Fabricate(:frequent_apple_run_time, name: "FrequentApple::SyncBagsJob", namespace: "tdr")
    Fabricate(:frequent_apple_run_time, name: "FrequentApple::SyncBagsJob", namespace: "sdr")
    Fabricate(:frequent_apple_run_time, name: "FrequentApple::SyncBagsJob", namespace: "chron")
    Fabricate(:frequent_apple_run_time, name: "FrequentApple::SyncBagsJob", namespace: "hathi")
  end

  context "when running_node=sdr" do
    before(:each) do
      @running_node = Node.find_by_namespace!("sdr") # this object will change when we clear the db
      @running_node_client = FrequentApple.client(@running_node.api_root, @running_node.auth_credential)
      @bag = Bag.find_by_uuid!("c6f2c6d6-dd4a-4afe-995f-c8d6c5970944") #see fixtures/bags.yml
    end

    subject {
      @all_namespaces.each do |_namespace|
        FrequentApple::SyncBagsJob.perform_now(_namespace, @running_node.namespace)
      end
    }

    context "when bag exists on running node" do
      context "when bag on tdr is missing" do
        before(:each) do
          tdr = Node.find_by_namespace!("tdr")
          @tdr_client = FrequentApple.client(tdr.api_root, tdr.auth_credential)
          @tdr_client.delete("/bag/#{@bag.uuid}")
        end
        include_examples "no change"
      end

      context "when bag on tdr is different" do
        before(:each) do
          tdr = Node.find_by_namespace!("tdr")
          @tdr_client = FrequentApple.client(tdr.api_root, tdr.auth_credential)
          response = @tdr_client.delete("/bag/#{@bag.uuid}")
          raise ArgumentError, response.body unless response.ok?
          @changed_bag_body = ApiV1::BagPresenter.new(@bag).to_hash
          @changed_bag_body[:local_id] = "changed_local_id"
          raise ArgumentError unless @tdr_client.post("/bag", @changed_bag_body.to_json).ok?
        end

        context "(older)" do
          before(:each) do
            sleep 1
            response = @running_node_client.delete("/bag/#{@bag.uuid}")
            raise ArgumentError, response.body unless response.ok?
            response = @running_node_client.post("/bag", ApiV1::BagPresenter.new(@bag).to_json)
            raise ArgumentError, response.body unless response.ok?
          end
          it "does not change running node's bag" do
            subject()
            response = @running_node_client.get("/bag/#{@bag.uuid}")
            expect(response.ok?).to be true
            bag = JSON.parse(response.body, symbolize_names: true)
            expect(bag[:local_id]).to eql(@bag.local_id)
          end
        end

        context "(newer)" do
          include_examples "change"
        end
      end

      context "when bag on tdr is the same" do
        context "(same timestamps)" do
          include_examples "no change"
        end

        context "(newer)" do
          before(:each) do
            tdr = Node.find_by_namespace!("tdr")
            @tdr_client = FrequentApple.client(tdr.api_root, tdr.auth_credential)
            response = @tdr_client.delete("/bag/#{@bag.uuid}")
            raise ArgumentError, response.body unless response.ok?
            raise ArgumentError unless @tdr_client.post("/bag", ApiV1::BagPresenter.new(@bag).to_json).ok?
          end
          include_examples "no change"
        end

      end
    end

    context "when bag does not exist on running node" do
      before(:each) do
        @running_node_client.delete("/bag/#{@bag.uuid}")
      end
      it "creates the bag" do
        subject()
        response = @running_node_client.get("/bag/#{@bag.uuid}")
        expect(response.ok?).to be true
        bag = JSON.parse(response.body, symbolize_names: true)
        bag[:replicating_nodes].sort!
        expect(bag).to match_without_timestamps(ApiV1::BagPresenter.new(@bag).to_hash)
      end
    end
  end
end
