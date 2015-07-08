require 'rails_helper'
require "frequent_apple"

def get_mapping(status, validity, fixity, cancelled)
  if cancelled
    return "cancelled"
  end

  case status
    when :requested
    when :rejected
      return "rejected"
    when :downloaded
    when :unpacked
      if fixity.blank? == false && validity != nil
        if validity == true
          return "received"
        else
          return "cancelled"
        end
      end
    when :preserved
      return "stored"
    else
      return nil
  end
  return nil
end


describe FrequentApple::UpdateReplicationStatusJob, type: :job do
  before(:each) do
    @local_node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
    @remote_node = Fabricate(:node)
    @repl = Fabricate(:replication_transfer_requested, from_node: @remote_node, to_node: @local_node)

    @local_client = double(:local_client)
    @remote_client = double(:remote_client)
    put_response = double(:put_response)
    allow(put_response).to receive(:ok?).and_return(true)
    allow(@local_client).to receive(:put).with(any_args).and_return(put_response)
    allow(@remote_client).to receive(:put).with(any_args).and_return(put_response)
    allow(FrequentApple).to receive(:client).with(@local_node.api_root, anything).and_return(@local_client)
    allow(FrequentApple).to receive(:client).with(@remote_node.api_root, anything).and_return(@remote_client)
    # allow(FrequentApple).to receive(:client).and_raise(ArgumentError, "test problem")
  end

  subject { FrequentApple::UpdateReplicationStatusJob.perform_now(@remote_node.namespace, @local_node.namespace) }

  example_fixity = Faker::Bitcoin.address

  [:requested, :rejected, :downloaded, :unpacked, :preserved].each do |status|
    context "when bag_mgr_request[:status]==#{status}" do
      [true, false, nil].each do |validity|
        context "when validity==#{validity}" do
          [nil, example_fixity].each do |fixity|
            context "when fixity==#{fixity}" do
              [true,false].each do |is_cancelled|
                context "when cancelled?==#{is_cancelled}" do
                  before(:each) do
                    @bag_mgr_request = Fabricate(:bag_manager_request, status: status,
                                                 fixity: fixity, validity: validity, cancelled: is_cancelled)
                    @repl.bag_mgr_request_id = @bag_mgr_request.id
                    @repl.save!
                    response = double(:response)
                    allow(response).to receive(:body).and_return(@bag_mgr_request.to_json)
                    allow(response).to receive(:ok?).and_return(true)
                    allow(@local_client).to receive(:get).with("/bag_mgr/#{@bag_mgr_request.id}").and_return(response)
                  end

                  it "raises no exceptions" do
                    expect { subject() }.to_not raise_error
                  end

                  # Should do nothing if no-op, or no change.
                  mapping = get_mapping(status, validity, fixity, is_cancelled)
                  if mapping == nil || mapping == "requested" #i.e. if status unchanged
                    it "attempts no changes" do
                      expect(@local_client).to_not receive(:put)
                      expect(@remote_client).to_not receive(:put)
                      subject()
                    end
                  else
                    it "has status == #{mapping} in the put" do
                      subject()
                      [@local_client, @remote_client].each do |client|
                        expect(client).to have_received(:put) do |url, json_body|
                          expect(url).to eql("/replicate/#{@repl.replication_id}")
                          body = JSON.parse(json_body, symbolize_names: true)
                          expect(body[:status]).to eql(mapping)
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

