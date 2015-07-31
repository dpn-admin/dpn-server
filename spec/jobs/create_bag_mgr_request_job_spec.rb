require 'rails_helper'
require "frequent_apple"

describe CreateBagManRequestJob, type: :job do
  before(:each) do
    Fabricate(:local_node, namespace: Rails.configuration.local_namespace)

    response = double(:response)
    allow(response).to receive(:body).and_return({id: rand(99999)}.to_json)
    allow(response).to receive(:status).and_return(200)
    allow(response).to receive(:ok?).and_return(true)

    @client = double(:client)
    allow(@client).to receive(:post).and_return(response)

    allow(FrequentApple).to receive(:client).and_return(@client)
    @replication_transfer = Fabricate(:replication_transfer)

    CreateBagManRequestJob.perform_now(@replication_transfer, Rails.configuration.local_namespace)
  end

  it "creates a BagManagerRequest" do
    expect(@client).to have_received(:post).with("/bag_man/requests", anything)
  end

  it "passes a json argument" do
    expect(@client).to have_received(:post) do |url, body|
      expect {
        JSON.parse(body, symbolize_names: true)
      }.to_not raise_error
    end
  end

  it "sets request.source_location to repl.link" do
    expect(@client).to have_received(:post) do |url, body|
      hash = JSON.parse(body, symbolize_names: true)
      expect(hash).to include(source_location: @replication_transfer.link)
    end
  end

  it "sets request.status to requested" do
    expect(@client).to have_received(:post) do |url, body|
      hash = JSON.parse(body, symbolize_names: true)
      expect(hash).to include(status: "requested")
    end
  end

  it "does not set request.fixity" do
    expect(@client).to have_received(:post) do |url, body|
      hash = JSON.parse(body, symbolize_names: true)
      expect(hash[:fixity]).to be_nil
    end
  end

  it "does not set request.validity" do
    
    expect(@client).to have_received(:post) do |url, body|
      hash = JSON.parse(body, symbolize_names: true)
      expect(hash[:validity]).to be_nil
    end
  end

  it "sets request.cancelled to false" do
    expect(@client).to have_received(:post) do |url, body|
      hash = JSON.parse(body, symbolize_names: true)
      expect(hash[:cancelled]).to be false
    end
  end

  it "sets repl.bag_man_request_id to the id" do
    expect(@replication_transfer.reload.bag_man_request_id).to_not be_nil
  end
end
