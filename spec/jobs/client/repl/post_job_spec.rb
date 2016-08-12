# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe Client::Repl::PostJob do

  describe "#normalize_args" do
    before(:each) do
      @record = Fabricate(:replication_transfer)
      @namespace = @record.from_node.namespace
      @query_type = :update
      @adapter_class = ReplicationTransferAdapter
      @job = Client::Repl::PostJob.new

      @remote_client = double(:remote_client)
      allow(@job).to receive(:remote_client).and_return @remote_client
    end

    subject {
      @job.normalize_args(
        @record, @namespace, @query_type.to_s, @adapter_class.to_s
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

    it "returns the record" do
      _, record, _ = subject
      expect(record).to eql(@record)
    end

    it "returns a the proper query" do
      _, _, query = subject
      expect(query.type).to eql(@query_type)
      expect(query.params).to eql(@adapter_class.from_model(@record).to_public_hash)
    end

  end


  describe "#post" do
    before(:each) do
      @record = double(:record)
      allow(@record).to receive(:cancelled?).and_return false

      @response = double(:response)
      allow(@response).to receive(:success?).and_return true
      allow(@response).to receive(:body).and_return({name: "the query"})

      @query = double(:query)

      @remote_client = double(:remote_client)
      allow(@remote_client).to receive(:execute).and_yield(@response)
    end

    subject { Client::Repl::PostJob.new.post(@remote_client, @record, @query) }

    context "when ours is not cancelled" do
      before(:each) { allow(@record).to receive(:cancelled?).and_return false }
      it "executes the query" do
        expect(@remote_client).to receive(:execute).with(@query)
        subject
      end
    end

    context "when ours is cancelled" do
      before(:each) { allow(@record).to receive(:cancelled?).and_return true }
      it "does not execute the query" do
        expect(@remote_client).to_not receive(:execute).with(@query)
        subject
      end
      it "succeeds" do
        expect {subject}.to_not raise_error
      end
    end

    context "when query succeeds" do
      before(:each) { allow(@response).to receive(:success?).and_return true }
      it "succeeds" do
        expect {subject}.to_not raise_error
      end
    end

    context "when query fails" do
      before(:each) { allow(@response).to receive(:success?).and_return false }
      it "errors" do
        expect {subject}.to raise_error RuntimeError, @response.body.to_s
      end
    end

  end

end