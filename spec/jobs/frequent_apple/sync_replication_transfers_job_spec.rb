require "rails_helper"
require "frequent_apple"

shared_examples "no changes" do
  it "makes no changes" do
    subject()
    response = @running_node_client.get("/replicate/#{@record.replication_id}")
    expect(response.ok?).to be true
    actual_record = JSON.parse(response.body, symbolize_names: true)
    expected_record = ApiV1::ReplicationTransferPresenter.new(@record).to_hash
    expect(actual_record).to match_without_timestamps(expected_record)
  end
end

describe FrequentApple::SyncReplicationTransfersJob, type: :integration do
  before(:all) do
    @all_namespaces = Node.all.collect { |n| n.namespace }
  end
  before(:each) do
    `bundle exec cap development rrake:all`
    `rake db:clear`
    `rake db:fixtures:load`
    Fabricate(:frequent_apple_run_time, name: "FrequentApple::SyncReplicationTransfersJob", namespace: "tdr")
    Fabricate(:frequent_apple_run_time, name: "FrequentApple::SyncReplicationTransfersJob", namespace: "sdr")
    Fabricate(:frequent_apple_run_time, name: "FrequentApple::SyncReplicationTransfersJob", namespace: "chron")
    Fabricate(:frequent_apple_run_time, name: "FrequentApple::SyncReplicationTransfersJob", namespace: "hathi")
    @running_node = Node.find_by_namespace!("sdr") # this object will change when we clear the db
    @running_node_client = FrequentApple.client(@running_node.api_root, @running_node.auth_credential)
  end

  after(:all) do
    `bundle exec cap development rrake:db:clear`
    `rake db:clear`
  end

  subject {
    @all_namespaces.each do |_namespace|
      FrequentApple::SyncReplicationTransfersJob.perform_now(_namespace, @running_node.namespace)
    end
  }


  context "when local node has the record" do
    before(:each) do
      @record = ReplicationTransfer.first
      # the rest is automated by fixtures
    end


    context "when theirs is newer and different" do
      before(:each) do
        their_node = Node.find_by_namespace("tdr")
        their_client = FrequentApple.client(their_node.api_root, their_node.auth_credential)
        response = their_client.delete("/replicate/#{@record.replication_id}")
        raise ArgumentError, response.body unless response.ok?
        @changed_body = ApiV1::ReplicationTransferPresenter.new(@record).to_hash
        @changed_body[:status] = "rejected"
        sleep 1
        response = their_client.post("/replicate/", @changed_body.to_json)
        raise ArgumentError, response.body unless response.ok?
      end
      it "updates the record" do
        subject()
        response = @running_node_client.get("/replicate/#{@record.replication_id}")
        expect(response.ok?).to be true
        actual_record = JSON.parse(response.body, symbolize_names: true)
        expect(actual_record).to match_without_timestamps(@changed_body)
      end
    end

    context "when theirs is newer and the same" do
      before(:each) do
        their_node = Node.find_by_namespace("tdr")
        their_client = FrequentApple.client(their_node.api_root, their_node.auth_credential)
        response = their_client.delete("/replicate/#{@record.replication_id}")
        raise ArgumentError, response.body unless response.ok?
        body = ApiV1::ReplicationTransferPresenter.new(@record)
        sleep 1
        response = their_client.post("/replicate/", body.to_json)
        raise ArgumentError, response.body unless response.ok?
      end
      include_examples "no changes"
    end

    context "when theirs is older and different" do
      before(:each) do
        response = @running_node_client.delete("/replicate/#{@record.replication_id}")
        raise ArgumentError, response.body unless response.ok?
        @expected_body = ApiV1::ReplicationTransferPresenter.new(@record).to_hash
        @expected_body[:status] = "rejected"
        sleep 1
        response = @running_node_client.post("/replicate/", @expected_body.to_json)
        raise ArgumentError, response.body unless response.ok?
      end
      it "makes no changes" do
        subject()
        response = @running_node_client.get("/replicate/#{@record.replication_id}")
        expect(response.ok?).to be true
        actual_record = JSON.parse(response.body, symbolize_names: true)
        expect(actual_record).to match_without_timestamps(@expected_body)
      end
    end

    context "when theirs is older and the same" do
      before(:each) do
        response = @running_node_client.delete("/replicate/#{@record.replication_id}")
        raise ArgumentError, response.body unless response.ok?
        body = ApiV1::ReplicationTransferPresenter.new(@record)
        sleep 1
        response = @running_node_client.post("/replicate/", body.to_json)
        raise ArgumentError, response.body unless response.ok?
      end
      include_examples "no changes"
    end
  end

  context "when local node doesn't have the record" do
    before(:each) do
      @record = ReplicationTransfer.first
      response = @running_node_client.delete("/replicate/#{@record.replication_id}")
      raise ArgumentError, response.body unless response.ok?
    end
    context "and they do" do
      # they already have it via fixtures
      it "creates the record" do
        subject()
        response = @running_node_client.get("/replicate/#{@record.replication_id}")
        expect(response.ok?).to be true
        actual_record = JSON.parse(response.body, symbolize_names: true)
        expected_record = ApiV1::ReplicationTransferPresenter.new(@record).to_hash
        expect(actual_record).to match_without_timestamps(expected_record)
      end
    end
  end

  it "updates the runtime" do
    subject()
    last_run = FrequentApple::RunTime.find_by_name!("FrequentApple::SyncReplicationTransfersJob")
    expect(last_run.last_run_time).to be > FrequentApple::RunTime.new(name: "blarg").last_run_time
  end



end