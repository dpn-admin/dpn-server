# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe BagManRequest, type: :model do

  FromNode = Struct.new("FromNode", :namespace)

  before(:each) { Fabricate(:local_node, namespace: Rails.configuration.local_namespace)}
  it "has a valid factory" do
    expect(Fabricate.build(:bag_man_request)).to be_valid
  end

  it "is invalid without a source_location" do
    expect(Fabricate.build(:bag_man_request, source_location: nil)).to_not be_valid
  end

  it "is invalid without a last_step_completed" do
    expect(Fabricate.build(:bag_man_request, last_step_completed: nil)).to_not be_valid
  end

  [:unpacked_location, :preservation_location, :fixity].each do |field|
    it "disallows changing a non-nil #{field}" do
      record = Fabricate(:bag_man_request, field => "/blah/blah")
      expect(record).to be_valid
      record.update(field => "/something/else")
      expect(record).to_not be_valid
    end
  end


  describe "#staging_location" do
    let(:staging_dir) { "/herpderp" }
    let(:source_location) { "hathi@chron.edu:/path/to/nameofthebag" }
    it "returns the staging location (w/o extension)" do
      request = Fabricate(:bag_man_request, source_location: source_location)
      expected = File.join staging_dir, request.id.to_s, "nameofthebag"
      expect(request.staging_location(staging_dir)).to eql(expected)
    end
    it "returns the staging location (w/ extension)" do
      request = Fabricate(:bag_man_request, source_location: source_location + ".tar" )
      expected = File.join staging_dir, request.id.to_s, "nameofthebag"
      expect(request.staging_location(staging_dir)).to eql(expected)
    end
  end

  describe "#cancel!" do
    context "when already cancelled" do
      let(:request) { Fabricate.build(:bag_man_request, cancelled: true)}
      it "does nothing" do
        previous_time = request.updated_at
        request.cancel!('testing')
        expect(request.updated_at).to eql(previous_time)
      end
    end

    context "when not cancelled" do
      before(:each) do
        @repl_mock = double(:replication_transfer)
        allow(@repl_mock).to receive(:cancel!)
        allow(@repl_mock).to receive(:from_node).and_return FromNode.new("fake_namespace")
        @request = Fabricate(:bag_man_request)
        allow(@request).to receive(:replication_transfer).and_return(@repl_mock)
        allow(Client::Repl::CancelJob).to receive(:perform_later)
      end
      it "sets the cancel_reason" do
        @request.cancel!('testing')
        expect(@request.reload.cancel_reason).to eql('testing')
      end
      it "calls replication_transfer.cancel!" do
        expect(@repl_mock).to receive(:cancel!)
        @request.cancel!('testing')
      end
      it "passes the reason to replication_transfer.cancel!" do
        expect(@repl_mock).to receive(:cancel!).with('testing')
        @request.cancel!('testing')
      end
      it "enqueues a Client::Repl::CancelJob" do
        expect(Client::Repl::CancelJob).to receive(:perform_later)
          .with(@repl_mock, "fake_namespace", "replicate",
            "update_replication", "ReplicationTransferAdapter")
        @request.cancel!('testing')
      end
    end
  end

  describe "#begin!" do
    let(:request) { Fabricate(:bag_man_request)}
    subject { request.begin! }
    it "enqueues a BagRetrievalJob with (self, staging_directory)" do
      staging_dir = Rails.configuration.staging_dir.to_s
      expect{subject}.to enqueue_a(Client::Repl::BagRetrievalJob)
        .with(global_id(request), staging_dir)
    end
  end

  describe "#okay_to_preserve!" do
    let(:request) { Fabricate(:bag_man_request, unpacked_location: "/unpacked/location")}
    subject { request.okay_to_preserve! }
    it "enqueues a BagPreserveJob with (self, unpacked_location, preservation_dir" do
      repo_dir = Rails.configuration.repo_dir.to_s
      expect{subject}.to enqueue_a(Client::Repl::BagPreserveJob)
        .with(global_id(request), request.unpacked_location, repo_dir)
    end
  end

  describe "#set_retrieved!" do
    let(:request) { Fabricate(:bag_man_request)}
    subject { request.set_retrieved!; request }
    it "sets last_step_completed to :retrieved" do
      expect(subject.retrieved?).to be true
    end
    it "enqueues a BagUnpackJob with (self, staging_location)" do
      expect{subject}.to enqueue_a(Client::Repl::BagUnpackJob)
        .with(global_id(request), request.staging_location)
    end
  end

  describe "#set unpacked!" do
    let(:request) { Fabricate(:bag_man_request)}
    let(:location) { "/l/d/a/sf/asdf/a"}
    subject { request.set_unpacked!(location); request }
    it "sets last_step_completed to :unpacked" do
      expect(subject.unpacked?).to be true
    end
    it "sets request.unpacked_location" do
      expect(subject.unpacked_location).to eql(location)
    end
    it "enqueues a BagValidateJob with (self, unpacked_location)" do
      expect{subject}.to enqueue_a(Client::Repl::BagValidateJob)
        .with(global_id(request), location)
    end
  end

  describe "#set_validated!" do
    let!(:request) { Fabricate(:bag_man_request, unpacked_location: "/adf/sdf/a/gd")}
    context "valid" do
      subject { request.set_validated!(true); request }
      it "sets last_step_completed to :validated" do
        expect(subject.validated?).to be true
      end
      it "enqueues a BagFixityJob with (self, unpacked_location)" do
        expect{subject}.to enqueue_a(Client::Repl::BagFixityJob)
          .with(global_id(request), request.unpacked_location)
      end
    end
    context "invalid" do
      before(:each) do
        allow(request).to receive(:cancel!)
      end
      subject { request.set_validated!(false); request }
      it "sets last_step_completed to :validated" do
        expect(subject.validated?).to be true
      end
      it "does not enqueue a BagFixityJob" do
        subject
        expect(ActiveJob::Base.queue_adapter.enqueued_jobs).to be_empty
        expect(ActiveJob::Base.queue_adapter.performed_jobs).to be_empty
      end
      it "calls #cancel! with bag_invalid" do
        allow(request).to receive(:cancel!)
        expect(subject).to have_received(:cancel!).with('bag_invalid')
      end
    end
  end

  # These tests are kind of gross because they will fail if we change
  # which methods we're using to update the replication transfer.
  # That said, it is mocked out effectively.
  describe "#set_fixityd!" do
    before(:each) do
      @fixity = Faker::Bitcoin.address
      @repl_mock = double(:replication_transfer)
      allow(@repl_mock).to receive(:update!).and_return(true)
      allow(@repl_mock).to receive(:from_node).and_return FromNode.new("fake_namespace")
      @request = Fabricate(:bag_man_request, unpacked_location: "/a/bc/d")
      allow(@request).to receive(:replication_transfer).and_return(@repl_mock)
      allow(Client::Repl::PostJob).to receive(:perform_later)
    end
    it "sets last_step_completed to :fixityd" do
      @request.set_fixityd!(@fixity)
      expect(@request.fixityd?).to be true
    end
    it "enqueues nothing" do
      @request.set_fixityd!(@fixity)
      expect(ActiveJob::Base.queue_adapter.enqueued_jobs).to be_empty
      expect(ActiveJob::Base.queue_adapter.performed_jobs).to be_empty
    end
    it "sets replication_transfer.fixity_value = fixity" do
      expect(@repl_mock).to receive(:update!).with({fixity_value: @fixity})
      @request.set_fixityd!(@fixity)
    end
    it "enqueues a Client::Repl::UpdateJob" do
      expect(Client::Repl::PostJob).to receive(:perform_later)
        .with(@repl_mock, "fake_namespace", "update_replication",
          "ReplicationTransferAdapter")
      @request.set_fixityd!(@fixity)
    end
  end

  # These tests are kind of gross because they will fail if we change
  # which methods we're using to update the replication transfer.
  # That said, it is mocked out effectively.
  describe "#set_stored!" do
    before(:each) do
      @location = "/sd/adsf/af/sdf/asdf/f"
      @repl_mock = double(:replication_transfer)
      allow(@repl_mock).to receive(:update!).and_return(true)
      allow(@repl_mock).to receive(:from_node).and_return FromNode.new("fake_namespace")
      @request = Fabricate(:bag_man_request, unpacked_location: "/sd/f/af")
      allow(@request).to receive(:replication_transfer).and_return(@repl_mock)
      allow(Client::Repl::PostJob).to receive(:perform_later)
    end
    it "sets last_step_completed to :stored" do
      @request.set_stored!(@location)
      expect(@request.stored?).to be true
    end
    it "sets request.preservation_location" do
      @request.set_stored!(@location)
      expect(@request.preservation_location).to eql(@location)
    end
    it "enqueues nothing" do
      @request.set_stored!(@location)
      expect(ActiveJob::Base.queue_adapter.enqueued_jobs).to be_empty
      expect(ActiveJob::Base.queue_adapter.performed_jobs).to be_empty
    end
    it "sets replication_transfer.stored = true" do
      expect(@repl_mock).to receive(:update!).with({stored: true})
      @request.set_stored!(@location)
    end
    it "enqueues a Client::Repl::UpdateJob" do
      expect(Client::Repl::PostJob).to receive(:perform_later)
        .with(@repl_mock, "fake_namespace", "update_replication",
          "ReplicationTransferAdapter")
      @request.set_stored!(@location)
    end
  end

end
