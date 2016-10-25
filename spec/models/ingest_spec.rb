# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Ingest do
  
  it "has a valid factory" do
    expect(Fabricate(:ingest)).to be_valid
  end

  describe "::find_fields" do
    it "returns its find fields" do
      expect(Ingest.find_fields).to eql(Set.new([:ingest_id]))
    end
  end
  
  describe "#ingest_id" do
    it "is required" do
      expect(Fabricate.build(:ingest, ingest_id: nil)).to_not be_valid
    end
    it "accepts a uuid" do
      expect(Fabricate.build(:ingest, ingest_id: SecureRandom.uuid)).to be_valid
    end
    it "rejects non-uuids" do
      expect(Fabricate.build(:ingest, ingest_id: "0128301923018301")).to_not be_valid
    end
    it "is read-only" do
      record = Fabricate(:ingest)
      expect(record.update(ingest_id: SecureRandom.uuid)).to be false
    end
  end
  
  describe "#ingested" do
    it "is required" do
      expect(Fabricate.build(:ingest, ingested: nil)).to_not be_valid
    end
    it "can be true or false" do
      expect(Fabricate.build(:ingest, ingested: true)).to be_valid
      expect(Fabricate.build(:ingest, ingested: false)).to be_valid
    end
    it "is read-only" do
      record = Fabricate(:ingest, ingested: true)
      expect(record.update(ingested: false)).to be false
    end
  end
  
  describe "#bag" do
    it "is required" do
      expect(Fabricate.build(:ingest, bag: nil)).to_not be_valid
    end
    it "is read-only" do
      record = Fabricate(:ingest)
      expect(record.update(bag: Fabricate(:bag))).to be false
    end
  end
  
  describe "#created_at" do
    it "can be set manually" do
      time = 10.years.ago.change(usec: 0)
      expect(Fabricate(:ingest, created_at: time).created_at).to eql(time)
    end
    it "is set automatically" do
      record = Ingest.create!(
        ingest_id: SecureRandom.uuid,
        ingested: true,
        bag: Fabricate(:bag)
      )
      
      expect(record.created_at).to_not be_nil
      expect(record.created_at).to be > 2.seconds.ago
    end
    it "is read-only" do
      record = Fabricate(:ingest)
      expect(record.update(created_at: Time.now)).to be false
    end
  end
  
  describe "#nodes" do
    it "accepts zero nodes" do
      expect(Fabricate.build(:ingest, nodes: [])).to be_valid
    end
    it "accepts multiple nodes" do
      expect(Fabricate.build(:ingest, nodes: Fabricate.times(rand(1..5), :node)))
    end
    it "can't have another added" do
      replicating_nodes = Fabricate.times(rand(1..5), :node)
      record = Fabricate(:ingest, nodes: replicating_nodes)
      expect {record.nodes << Fabricate(:node) }.to raise_error ActiveRecord::RecordInvalid
      expect(record.reload.nodes.size).to eql(replicating_nodes.size)
    end
    it "can't have one destroyed" do
      replicating_nodes = Fabricate.times(rand(1..5), :node)
      record = Fabricate(:ingest, nodes: replicating_nodes)
      expect {record.nodes.destroy(record.nodes.first)}.to raise_error ActiveRecord::RecordInvalid
      expect(record.reload.nodes.size).to eql(replicating_nodes.size)
    end
  end

  describe "scope latest_only", :broken_in_sqlite do
    before(:each) do
      @bag1 = Fabricate(:bag)
      @bag2 = Fabricate(:bag)
      @latest1 = Fabricate(:ingest, bag: @bag1, created_at: 2.hours.from_now)
      Fabricate(:ingest, bag: @bag1, created_at: 1.hour.ago)
      @latest2 = Fabricate(:ingest, bag: @bag2, created_at: 2.hours.ago)
      Fabricate(:ingest, bag: @bag2, created_at: 1.day.ago)
    end
    it "returns only the latest record for each bag" do
      expect(Ingest.latest_only(true)).to contain_exactly @latest1, @latest2
    end

    it "returns only the latest ingest for the specified bag" do
      expect(Ingest.where(bag: @bag1).latest_only(true)).to contain_exactly @latest1
    end
  end

  it_behaves_like "it has temporal scopes for", :created_at

  describe "scope with_ingested" do
    it_behaves_like "a boolean filter" do
      let(:scope_name) { :with_ingested }
      let(:field_name) { :ingested }
    end
  end

  
end