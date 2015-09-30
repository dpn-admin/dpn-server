# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Bag do
  it "has a valid factory" do
    expect(Fabricate.build(:bag)).to be_valid
  end

  it "is invalid if only the timestamps changed" do
    bag = Fabricate(:bag)
    bag.updated_at = Time.now
    expect(bag.save).to be false
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
    it "disallows changing" do
      bag = Fabricate(:bag)
      bag.admin_node = Fabricate(:node)
      expect(bag.save).to be false
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

  describe "fixity_checks" do
    it "can be empty" do
      expect(Fabricate.build(:bag, fixity_checks: [])).to be_valid
    end
    it "allows adding them" do
      bag = Fabricate(:bag)
      bag.fixity_checks << FixityCheck.new(value: Faker::Bitcoin.address, fixity_alg: Fabricate(:fixity_alg) )
      bag.fixity_checks << FixityCheck.new(value: Faker::Bitcoin.address, fixity_alg: Fabricate(:fixity_alg) )
      expect(bag.save).to be true
    end
  end

end
