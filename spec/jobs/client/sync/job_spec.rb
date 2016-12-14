# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Client::Sync::Job do

  time = Time.now.change(usec: 0)
  public_hash = "{foo: 1, bar: 2, baz: 3}"
  model_hash = {foo: 1, bar: 2}

  describe "#perform" do
    let(:job) do
      job = Client::Sync::Job.new
      allow(job).to receive(:remote_client)
      allow(job).to receive(:query_builder)
      allow(job).to receive(:sync)
      job
    end

    subject { job.perform("some_name", "some_namespace", "Fixnum", "String", "Time") }

    it "creates a remote client" do
      expect(job).to receive(:remote_client).with("some_namespace")
      subject
    end
    it "creates a query builder" do
      expect(job).to receive(:query_builder).with(Fixnum, "some_namespace")
      subject
    end
    it "creates an adapter class" do
      expect(job).to receive(:sync).with(anything(), anything(), anything(), String, anything())
      subject
    end
    it "creates a CreatorUpdater" do
      expect(job).to receive(:sync)
        .with(anything(), anything(), anything(), anything(), Client::Sync::CreatorUpdater)
      subject
    end
    it "passes the model class to the Client::Sync::CreatorUpdater" do
      expect(Client::Sync::CreatorUpdater).to receive(:new).with(Time)
      subject
    end
  end



  describe "#sync" do
    let(:last_success_manager) do
      last_success_manager = double(:last_success_manager)
      allow(last_success_manager).to receive(:manage).and_yield(time, Time.now.change(usec: 0))
      last_success_manager
    end

    let(:response) do
      response = double(:response)
      allow(response).to receive(:body).and_return(public_hash)
      allow(response).to receive(:success?).and_return true
      response
    end

    let(:remote_client) do
      remote_client = double(:remote_client)
      allow(remote_client).to receive(:execute).and_yield(response)
      remote_client
    end

    let(:query_builder) do
      query_builder = double(:query_builder)
      allow(query_builder).to receive(:queries).and_return([:query1, :query2])
      query_builder
    end

    let(:adapter) do
      adapter = double(:adapter)
      allow(adapter).to receive(:to_model_hash).and_return(model_hash)
      adapter
    end

    let(:adapter_class) do
      adapter_class = double(:adapter_class)
      allow(adapter_class).to receive(:from_public).and_return(adapter)
      adapter_class
    end

    let(:updater) do
      updater = double(:updater)
      allow(updater).to receive(:update!)
      updater
    end

    subject { Client::Sync::Job.new.sync(last_success_manager, remote_client, query_builder, adapter_class, updater) }

    it "asks for queries from query builder" do
      expect(query_builder).to receive(:queries).with(time)
      subject
    end
    it "executes queries on remote client" do
      expect(remote_client).to receive(:execute).with(:query1)
      expect(remote_client).to receive(:execute).with(:query2)
      subject
    end
    it "passes the public hash to the adapter class" do
      expect(adapter_class).to receive(:from_public).with(public_hash)
      subject
    end
    it "gets the model_hash from the adapter" do
      expect(adapter).to receive(:to_model_hash)
      subject
    end
    it "raises an exception if the response was unsuccessful" do
      allow(response).to receive(:success?).and_return false
      expect {
        subject
      }.to raise_error(RuntimeError, public_hash)
    end
    it "passes the model_hash to the updater" do
      expect(updater).to receive(:update!).with(model_hash)
      subject
    end
    it "uses the last success manager to manage timestamps" do
      expect(last_success_manager).to receive(:manage)
      subject
    end
  end
  
  
end