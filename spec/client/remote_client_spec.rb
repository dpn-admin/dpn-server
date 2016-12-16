# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Client::RemoteClient do
  
  class Config
    attr_accessor :api_root, :auth_token, :logger
  end
  
  before(:each) do
    @config = Config.new
    @response = double(:response)
    
    @query = double(:query)
    allow(@query).to receive(:type).and_return(:some_type)
    allow(@query).to receive(:params).and_return({some: "value"})
    
    @client = double(:client)
    allow(@client).to receive(:configure).and_yield(@config).and_return(@client)
    allow(@client).to receive(@query.type).and_yield(@response)

    @connection = double(:connection)
    allow(@client).to receive(:connection).and_return(@connection)
    allow(@connection).to receive(:reset_all)
    
    allow(DPN::Client).to receive(:client).and_return(@client)
  end
  
  
  let!(:remote_client) { Client::RemoteClient.new("root", "cred", "logger")}
  let(:executed) { remote_client.execute(@query) {} }
  
  
  it "does not connect on initialize" do
    remote_client
    expect(DPN::Client).to_not have_received(:client)
  end
    
    
  it "creates the correct connection" do
    executed
    expect(@config.api_root).to eql("root")
    expect(@config.auth_token).to eql("cred")
    expect(@config.logger).to eql("logger")
  end
  
  
  it "calls query.type on the connection" do
    expect(@client).to receive(@query.type)
    executed
  end
  
  
  it "passes query.params to the connection" do
    expect(@client).to receive(@query.type).with(@query.params)
    executed
  end
  
  
  it "yields the response" do
    expect(@client).to receive(@query.type).and_yield(@response)
    executed
  end
  
  
end