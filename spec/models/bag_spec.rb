# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Bag do
  it "has a valid factory" do
    expect(Fabricate.build(:bag)).to be_valid
  end
  
  it "has a factory that honors updated_at" do
    time = 1.year.ago
    bag = Fabricate(:bag, updated_at: 1.year.ago)
    expect(bag.updated_at.change(usec: 0)).to eql time.change(usec: 0)
  end
  
  describe "::find_fields" do
    it "returns its find fields" do
      expect(Bag.find_fields).to eql(Set.new([:uuid]))
    end
  end

  describe "uuid" do
    it "is required" do
      expect(Fabricate.build(:bag, uuid: nil)).to_not be_valid
    end
    it "disallows changing" do
      bag = Fabricate(:bag)
      bag.uuid = SecureRandom.uuid
      expect(bag.save).to be false
    end
    it "only accepts valid uuids" do
      expect(Fabricate.build(:bag, uuid: "someuuid")).to_not be_valid
    end
  end

  describe "ingest_node" do
    it "is required" do
      expect(Fabricate.build(:bag, ingest_node: nil)).to_not be_valid
    end
    it "disallows changing" do
      bag = Fabricate(:bag)
      bag.ingest_node = Fabricate(:node)
      expect(bag.save).to be false
    end
  end

  describe "admin_node" do
    it "is required" do
      expect(Fabricate.build(:bag, admin_node: nil)).to_not be_valid
    end
    it "allows changing" do
      bag = Fabricate(:bag)
      bag.admin_node = Fabricate(:node)
      expect(bag.save).to be true
    end
  end

  describe "member" do 
    it "is required" do
      expect(Fabricate.build(:bag, member: nil)).to_not be_valid
    end
    it "allows changing" do
      bag = Fabricate(:bag)
      bag.member = Fabricate(:member)
      expect(bag.save).to be true
    end
  end

  describe "local_id" do
    it "is required" do
      expect(Fabricate.build(:bag, local_id: nil)).to_not be_valid
    end
    it "allows changing" do
      bag = Fabricate(:bag)
      bag.local_id = Faker::Address.street_name
      expect(bag.save).to be true
    end
  end

  describe "size" do
    it "is required" do
      expect(Fabricate.build(:bag, size: nil)).to_not be_valid
    end
    it "must be >= 1" do
      expect(Fabricate.build(:bag, size: 0)).to_not be_valid
      expect(Fabricate.build(:bag, size: -1)).to_not be_valid
    end
    it "disallows changing" do
      bag = Fabricate(:bag)
      bag.size = bag.size + 1
      expect(bag.save).to be false
    end
  end

  describe "version" do
    it "is required" do
      expect(Fabricate.build(:bag, version: nil)).to_not be_valid
    end
    it "must be >= 1" do
      expect(Fabricate.build(:bag, version: 0)).to_not be_valid
      expect(Fabricate.build(:bag, version: -1)).to_not be_valid
    end
    it "disallows changing" do
      bag = Fabricate(:bag)
      bag.version = bag.version + 1
      expect(bag.save).to be false
    end
  end

  describe "version_family" do
    it "is required" do
      expect(Fabricate.build(:bag, version_family: nil)).to_not be_valid
    end
    it "disallows changing" do
      bag = Fabricate(:bag)
      bag.version_family = Fabricate(:version_family)
      expect(bag.save).to be false
    end
  end

  describe "replication_transfers" do
    it "can be empty" do
      expect(Fabricate.build(:bag, replication_transfers: [])).to be_valid
    end
  end

  describe "restore_transfers" do
    it "can be empty" do
      expect(Fabricate.build(:bag, restore_transfers: [])).to be_valid
    end
  end

  describe "replicating_nodes" do
    it "updates updated_at when added" do
      bag = Fabricate(:bag, updated_at: 2.hours.ago)
      bag.replicating_nodes << Fabricate(:node)
      bag.save
      expect(bag.updated_at).to be > 2.hours.ago
    end
  end

  it_behaves_like "it has temporal scopes for", :updated_at

  describe "scope with_admin_node" do
    let!(:bag) { Fabricate(:bag) }
    let!(:other_bag) { Fabricate(:bag) }
    it "includes matching only" do
      expect(Bag.with_admin_node(bag.admin_node)).to match_array [bag]
    end
    it "does not filter given a new record" do
      expect(Bag.with_admin_node(Fabricate.build(:node))).to contain_exactly(bag, other_bag)
    end
  end

  describe "scope with_ingest_node" do
    let!(:bag) { Fabricate(:bag) }
    let!(:other_bag) { Fabricate(:bag) }
    it "includes matching only" do
      expect(Bag.with_ingest_node(bag.ingest_node)).to match_array [bag]
    end
    it "does not filter given a new record" do
      expect(Bag.with_ingest_node(Fabricate.build(:node))).to contain_exactly(bag, other_bag)
    end
  end

  describe "scope with_member" do
    let!(:bag) { Fabricate(:bag) }
    let!(:other_bag) { Fabricate(:bag) }
    it "includes matching only" do
      expect(Bag.with_member(bag.member)).to match_array [bag]
    end
    it "does not filter given a new record" do
      expect(Bag.with_member(Fabricate.build(:member))).to contain_exactly(bag, other_bag)
    end
  end

  describe "scope with_bag_type" do
    let!(:data_bag) { Fabricate(:data_bag) }
    let!(:rights_bag) { Fabricate(:rights_bag) }
    let!(:interpretive_bag) { Fabricate(:interpretive_bag) }
    it "includes matching only" do
      expect(Bag.with_bag_type(rights_bag.type)).to include(rights_bag)
      expect(Bag.with_bag_type(rights_bag.type)).to_not include(data_bag, interpretive_bag)
    end
  end

  describe "scope replicated_by" do
    before(:each) do
      Bag.destroy_all
      @nodes = Fabricate.times(3, :node)
      @bags = Fabricate.times(3, :bag)

      (0..2).to_a.each do |i|
        @bags[i].replicating_nodes = [@nodes[i]]
      end

      @bag12 = Fabricate(:bag)
      @bag12.replicating_nodes = [@nodes[1], @nodes[2]]

    end

    context "replicated_by nodes[0]" do
      it "includes bags[0]" do
        expect(Bag.replicated_by([@nodes[0]])).to include @bags[0]
      end
      it "excludes bags[1], bags[2], bag12" do
        expect(Bag.replicated_by([@nodes[0]])).to_not include @bags[1]
        expect(Bag.replicated_by([@nodes[0]])).to_not include @bags[2]
        expect(Bag.replicated_by([@nodes[0]])).to_not include @bag12
      end
    end

    context "replicated_by nodes[1]" do
      it "includes bags[1], bag12" do
        expect(Bag.replicated_by([@nodes[1]])).to include @bags[1]
        expect(Bag.replicated_by([@nodes[1]])).to include @bag12
      end
      it "excludes bags[0], bags[2]" do
        expect(Bag.replicated_by([@nodes[1]])).to_not include @bags[0]
        expect(Bag.replicated_by([@nodes[1]])).to_not include @bags[2]
      end
    end

    context "replicated_by nodes[0], nodes[2]" do
      it "includes bags[0], bags[2], bag12" do
        expect(Bag.replicated_by([@nodes[0], @nodes[2]])).to include @bags[0]
        expect(Bag.replicated_by([@nodes[0], @nodes[2]])).to include @bags[2]
        expect(Bag.replicated_by([@nodes[0], @nodes[2]])).to include @bag12
      end
      it "excludes bags[1]" do
        expect(Bag.replicated_by([@nodes[0], @nodes[2]])).to_not include @bags[1]
      end
    end

  end




  
end
