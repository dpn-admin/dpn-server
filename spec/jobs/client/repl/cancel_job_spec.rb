# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe Client::Repl::CancelJob do

  describe "#normalize_args" do
    before(:each) do
      @record = Fabricate(:replication_transfer)
      @namespace = @record.from_node.namespace
      @get_query_type = :get
      @cancel_query_type = :cancel
      @adapter_class = ReplicationTransferAdapter
      @job = Client::Repl::CancelJob.new

      @remote_client = double(:remote_client)
      allow(@job).to receive(:remote_client).and_return @remote_client
    end

    subject {
      @job.normalize_args(
        @record, @namespace, @get_query_type.to_s,
        @cancel_query_type.to_s, @adapter_class.to_s
      )
    }

    it "calls #remote_client with namespace" do
      expect(@job).to receive(:remote_client).with(@namespace)
      subject
    end

    it "returns the remote_client" do
      rc, _, _ = subject
      expect(rc).to eql(@remote_client)
    end

    it "returns a proper get_query" do
      _, query, _ = subject
      expect(query.type).to eql(@get_query_type)
      expect(query.params).to eql({})
    end

    it "returns a proper cancel_query" do
      _, _, query = subject
      expect(query.type).to eql(@cancel_query_type)
      expect(query.params).to eql(@adapter_class.from_model(@record).to_public_hash)
    end

  end


  describe "#cancel" do
    before(:each) do
      @get_response = double(:get_response)
      allow(@get_response).to receive(:success?).and_return true
      allow(@get_response).to receive(:body).and_return({name: "get"})

      @cancel_response = double(:cancel_response)
      allow(@cancel_response).to receive(:success?).and_return true
      allow(@cancel_response).to receive(:body).and_return({name: "cancel"})

      @get_query = double(:get_query)
      @cancel_query = double(:cancel_query)

      @remote_client = double(:remote_client)
      allow(@remote_client).to receive(:execute).with(@get_query).and_yield(@get_response)
      allow(@remote_client).to receive(:execute).with(@cancel_query).and_yield(@cancel_response)
    end

    subject { Client::Repl::CancelJob.new.cancel(@remote_client, @get_query, @cancel_query) }

    it "executes the get query" do
      expect(@remote_client).to receive(:execute).with(@get_query)
      subject
    end
    context "when get" do
      before(:each) do
        allow(@get_response).to receive(:success?).and_return true
      end
      it "executes the cancel query" do
        expect(@remote_client).to receive(:execute).with(@cancel_query)
        subject
      end
    end
    context "when get fails" do
      before(:each) do
        allow(@get_response).to receive(:success?).and_return false
      end
      it "errors" do
        expect {subject}.to raise_error(RuntimeError, @get_response.body.to_s)
      end
      it "does not execute the cancel query" do
        expect(@remote_client).to_not receive(:execute).with(@cancel_query)
        expect {subject}.to raise_error RuntimeError
      end
    end
    context "when get succeeds, already cancelled" do
      before(:each) do
        allow(@get_response).to receive(:success?).and_return true
        allow(@get_response).to receive(:body).and_return({cancelled: true})
      end
      it "succeeds" do
        expect {subject}.to_not raise_error
      end
      it "does not execute the cancel query" do
        expect(@remote_client).to_not receive(:execute).with(@cancel_query)
        subject
      end
    end
    context "when get succeeds, cancel succeeds" do
      before(:each) do
        allow(@get_response).to receive(:success?).and_return true
        allow(@cancel_response).to receive(:success?).and_return true
      end
      it "succeeds" do
        expect {subject}.to_not raise_error
      end
    end
    context "when get succeeds, cancel fails" do
      before(:each) do
        allow(@get_response).to receive(:success?).and_return true
        allow(@cancel_response).to receive(:success?).and_return false
      end
      it "errors" do
        expect {subject}.to raise_error RuntimeError, @cancel_response.body.to_s
      end
    end


  end

end