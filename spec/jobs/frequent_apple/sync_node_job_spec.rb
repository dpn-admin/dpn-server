require 'rails_helper'
require "frequent_apple"

describe FrequentApple::SyncNodeJob, type: :integration do
  before(:each) do
    `bundle exec cap development rrake:all`
    `rake db:clear`
    `rake db:fixtures:load`
  end

  context "when running_node=sdr" do
    before(:all) do
      @all_namespaces = Node.all.collect { |n| n.namespace }
    end
    before(:each) do
      @running_node = Node.find_by_namespace!("sdr") # this object will change when we clear the db
      @running_node_client = FrequentApple.client(@running_node.api_root, @running_node.auth_credential)
    end

    subject {
      @all_namespaces.each do |_namespace|
        FrequentApple::SyncNodeJob.perform_now(_namespace, @running_node.namespace)
      end
    }

    context "when tdr node on tdr has changed" do
      before(:each) do
        tdr = Node.find_by_namespace!("tdr")
        @name = "falsdfjasdfhaskdjhfalskfhalsdkfjhasldf"
        tdr_post_body = ApiV1::NodePresenter.new(tdr).to_hash
        tdr_post_body[:name] = @name
        tdr_client = FrequentApple.client(tdr.api_root, tdr.auth_credential)
        response = tdr_client.put("/node/tdr", tdr_post_body.to_json)
        raise ArgumentError, response.body unless response.ok?
      end

      it "should update tdr's record on the running node" do
        subject()
        body = JSON.parse(@running_node_client.get("/node/tdr").body, symbolize_names: true)
        expect(body[:name]).to eql(@name)
      end

    end

    context "when tdr node doesn't exist on tdr" do
      before(:each) do
        @tdr = Node.find_by_namespace!("tdr")
        tdr_client = FrequentApple.client(@tdr.api_root, @tdr.auth_credential)
        tdr_client.delete("/node/tdr")
      end
      it "should not delete tdr's record on the running node" do
        subject()
        response = @running_node_client.get("/node/tdr")
        expect(response.ok?).to be true
        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:name]).to eql(@tdr.name)
      end
    end

    context "when sdr node doesn't exist on running_node" do
      before(:each) do
        response = @running_node_client.delete("/node/sdr")
        raise ArgumentError, response.body unless response.ok?
      end
      it "should not create sdr's record on the running node" do
        begin
          subject()
        rescue JSON::ParserError
        end
        response = @running_node_client.get("/node/sdr")
        expect(response.status).to eql(404)
      end
    end

  end
end
