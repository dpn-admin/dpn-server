# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe ApiV1::BagPresenter do
  describe "sanity" do
    it "has a valid factory" do
      expect(Fabricate(:bag)).to be_valid
    end

    it "can be built" do
      bag = Fabricate(:data_bag)
      expect {
        presenter = ApiV1::BagPresenter.new(bag)
        expect(presenter).to_not be_nil
      }.to_not raise_error
    end
  end

  describe "#to_hash" do
    before(:each) do
      bag = Fabricate(:data_bag)
      @presenter = ApiV1::BagPresenter.new(bag)
    end

    before(:all) do
      @uuid_pattern = /\A[a-f0-9]{8}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{12}\Z/
    end

    it "returns a hash" do
      expect(@presenter.to_hash).to be_a(Hash)
    end

    it "returns a uuid" do
      expect(@presenter.to_hash[:uuid]).to match(@uuid_pattern)
    end

    it "returns a local_id" do
      id = @presenter.to_hash[:local_id]
      expect(id).to be_a(String)
      expect(id).to_not eql("")
    end

    it "returns a size" do
      expect(@presenter.to_hash[:size]).to be > 1
    end

    it "returns a first_version_uuid" do
      expect(@presenter.to_hash[:first_version_uuid]).to match(@uuid_pattern)
    end

    it "returns an ingest_node" do
      ingest_node = @presenter.to_hash[:ingest_node]
      expect(ingest_node).to be_a(String)
      expect(ingest_node).to_not eql("")
    end

    it "returns an admin_node" do
      admin_node = @presenter.to_hash[:admin_node]
      expect(admin_node).to be_a(String)
      expect(admin_node).to_not eql("")
    end

    it "returns a version" do
      expect(@presenter.to_hash[:version]).to be >= 1
    end

    it "returns a bag_type" do
      bag_type = @presenter.to_hash[:bag_type]
      expect(["D", "I", "R"]).to include(bag_type)
    end

    it "returns interpretive" do
      interpetive = @presenter.to_hash[:interpretive]
      expect(interpetive).to be_an(Array)
      interpetive.each do |uuid|
        expect(uuid).to match(@uuid_pattern)
      end
    end

    it "returns rights" do
      rights = @presenter.to_hash[:rights]
      expect(rights).to be_an(Array)
      rights.each do |uuid|
        expect(uuid).to match(@uuid_pattern)
      end
    end

    it "returns replicating_nodes" do
      replicating_nodes = @presenter.to_hash[:replicating_nodes]
      expect(replicating_nodes).to be_an(Array)
      replicating_nodes.each do |node|
        expect(node).to be_a(String)
        expect(node).to_not eql("")
      end
    end

    it "returns fixities" do
      fixities = @presenter.to_hash[:fixities]
      expect(fixities).to be_a(Hash)
      fixities.each do |fixity|
        expect(fixity).to be_a(String)
        expect(fixity).to_not eql("")
        expect(fixities[fixity]).to be_a(String)
        expect(fixities[fixity]).to_not eql("")
      end
    end

    it "returns created_at" do
      created_at = @presenter.to_hash[:created_at]
      through_datetime = DateTime.strptime(created_at, Time::DATE_FORMATS[:dpn]).strftime(Time::DATE_FORMATS[:dpn])
      expect(created_at).to eql(through_datetime)
    end

    it "returns updated_at" do
      updated_at = @presenter.to_hash[:updated_at]
      through_datetime = DateTime.strptime(updated_at, Time::DATE_FORMATS[:dpn]).strftime(Time::DATE_FORMATS[:dpn])
      expect(updated_at).to eql(through_datetime)
    end

    it "returns times in UTC" do
      time = Time.current.utc
      bag = Fabricate(:data_bag, created_at: time, updated_at: time)
      hash = ApiV1::BagPresenter.new(bag).to_hash
      expect(hash[:created_at]).to eql(time.to_formatted_s(:dpn))
      expect(hash[:updated_at]).to eql(time.to_formatted_s(:dpn))
    end

    it "returns member name" do
     member_name = @presenter.to_hash[:member]
     expect(member_name).to be_a(String)
     expect(member_name).to_not eql("")
    end
    
  end
end













