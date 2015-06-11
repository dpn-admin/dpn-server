require 'rails_helper'
require "frequent_apple"

describe RemoveOrphanBagMgrRequestsJob, type: :job do
  before(:each) do
    @local_node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
  end

  subject { RemoveOrphanBagMgrRequestsJob.perform_now() }

  [:cancelled, :stored, :rejected].each do |repl_status|
    context "when repl status is #{repl_status}" do
      before(:each) do
        @replication_transfer = Fabricate(:"replication_transfer_#{repl_status}", to_node: @local_node)
        @client = double(:client)
        allow(FrequentApple).to receive(:client).and_return(@client)
      end

      context "when BagMgrRequest exists" do
        before(:each) do
          @bag_mgr_request = Fabricate(:bag_manager_request)
          @replication_transfer.bag_mgr_request_id = @bag_mgr_request.id
          @replication_transfer.save!
          response = double(:response)
          allow(response).to receive(:ok?).and_return(true)
          allow(@client).to receive(:delete).and_return(response)
        end
        it "raises no exceptions" do
          expect {subject}.to_not raise_error
        end
        it "requests a deletion" do
          subject()
          expect(@client).to have_received(:delete).with("/bag_mgr/requests/#{@bag_mgr_request.id}")
        end
        it "sets bag_mgr_request_id to nil" do
          subject()
          expect(@replication_transfer.reload.bag_mgr_request_id).to be_nil
        end
      end

      context "when BagMgrRequest doesn't exist" do
        before(:each) do
          @replication_transfer.bag_mgr_request_id = rand(9999)
          @replication_transfer.save!
          response = double(:response)
          allow(response).to receive(:ok?).and_return(false)
          allow(response).to receive(:status).and_return(404)
          allow(@client).to receive(:delete).and_return(response)
        end
        it "raises no exceptions" do
          expect {subject}.to_not raise_error
        end
        it "sets bag_mgr_request_id to nil" do
          subject()
          expect(@replication_transfer.reload.bag_mgr_request_id).to be_nil
        end
      end

    end
  end



end
