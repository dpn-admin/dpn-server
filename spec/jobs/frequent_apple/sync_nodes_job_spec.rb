require 'rails_helper'
require "frequent_apple"

describe FrequentApple::SyncNodesJob, type: :integration do
  before(:each) do
    `bundle exec cap development rrake:all`
    `rake db:clear`
    `rake db:fixtures:load`
  end

  context "running_node=sdr" do
    # before(:all) do
    before(:each) do
      @running_node = Node.find_by_namespace!("sdr") # this object will change when we clear the db
      @running_node_client = FrequentApple.client(@running_node.api_root, @running_node.auth_credential)
    end

    subject { FrequentApple::SyncNodesJob.perform_now(@running_node.namespace) }
    context "tdr node has changed" do
      before(:each) do
        tdr = Node.find_by_namespace!("tdr")
        tdr_post_body = ApiV1::NodePresenter.new(tdr).to_hash
        @time = DateTime.now.strftime(Time::DATE_FORMATS[:dpn])
        @name = "falsdfjasdfhaskdjhfalskfhalsdkfjhasldf"
        tdr_post_body[:name] = @name
        tdr_post_body[:updated_at] = @time
        @tdr_client = FrequentApple.client(tdr.api_root, tdr.auth_credential)
        @tdr_client.put("/node/tdr", tdr_post_body.to_json)
      end

      it "should update tdr's record on the running node" do
        subject()
        body = JSON.parse(@running_node_client.get("/node/tdr").body, symbolize_names: true)
        expect(body).to be_a(Hash)
        expect(body[:name]).to eql(@name)
        expect(DateTime.strptime(body[:updated_at])).to be > DateTime.strptime(@time)
      end

    end

    context "tdr node doesn't exist on tdr" do
      before(:each) do
        tdr = Node.find_by_namespace!("tdr")
        @tdr_client = FrequentApple.client(tdr.api_root, tdr.auth_credential)
        @tdr_client.delete("/node/tdr")
      end
      it "should not delete tdr's record on the running node" do
        subject()
        response = @running_node_client.get("/node/tdr")
        expect(response.ok?).to be true
        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:namespace]).to eql("tdr")
      end
    end

    context "tdr node doesn't exist on running_node" do
      before(:each) do
        @running_node_client.delete("/node/tdr")
      end
      it "should not create tdr's record on the running node" do
        subject()
        response = @running_node_client.get("/node/tdr")
        expect(response.status).to eql(404)
      end
    end

  end
end
