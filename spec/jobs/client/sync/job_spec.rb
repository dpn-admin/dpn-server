# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Client::Sync::Job do

  time = Time.now.change(usec: 0)
  public_hash = "{foo: 1, bar: 2, baz: 3}"
  model_hash = {foo: 1, bar: 2}
  
  before(:each) do
    @last_success_manager = double(:last_success_manager)
    allow(@last_success_manager).to receive(:manage).and_yield(time, Time.now.change(usec: 0))
    
    @response = double(:response)
    allow(@response).to receive(:body).and_return(public_hash)
    allow(@response).to receive(:success?).and_return true
    @remote_client = double(:remote_client)
    allow(@remote_client).to receive(:execute).and_yield(@response)
    
    @query_builder = double(:query_builder)
    allow(@query_builder).to receive(:queries).and_return([:query1, :query2])

    @adapter = double(:adapter)
    allow(@adapter).to receive(:to_model_hash).and_return(model_hash)
    @adapter_class = double(:adapter_class)
    allow(@adapter_class).to receive(:from_public).and_return(@adapter)
    
    @updater = double(:updater)
    allow(@updater).to receive(:update!)
    
  end


  subject { Client::Sync::Job.new.sync(@last_success_manager, @remote_client, @query_builder, @adapter_class, @updater) }
  
  it "asks for queries from query builder" do
    expect(@query_builder).to receive(:queries).with(time)
    subject
  end
  it "executes queries on remote client" do
    expect(@remote_client).to receive(:execute).with(:query1)
    expect(@remote_client).to receive(:execute).with(:query2)
    subject
  end
  it "passes the public hash to the adapter class" do
    expect(@adapter_class).to receive(:from_public).with(public_hash)
    subject
  end
  it "gets the model_hash from the adapter" do
    expect(@adapter).to receive(:to_model_hash)
    subject
  end
  it "raises an exception if the response was unsuccessful" do
    allow(@response).to receive(:success?).and_return false
    expect {
      subject
    }.to raise_error(RuntimeError, public_hash)
  end
  it "passes the model_hash to the updater" do
    expect(@updater).to receive(:update!).with(model_hash)
    subject
  end
  it "uses the last success manager to manage timestamps" do
    expect(@last_success_manager).to receive(:manage)
    subject
  end
  
  
  
end