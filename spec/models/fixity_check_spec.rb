# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe FixityCheck do
  it "has a valid factory" do
    expect(Fabricate(:fixity_check)).to be_valid
  end

  describe "::find_fields" do
    it "returns its find fields" do
      expect(FixityCheck.find_fields).to eql(Set.new([:fixity_check_id]))
    end
  end

  [:fixity_check_id, :bag, :node, :success, :fixity_at, :created_at].each do |field|
    it "is invalid without a #{field}" do
      expect(Fabricate.build(:fixity_check, field => nil)).to_not be_valid
    end

    it "disallows changing #{field}" do
      record = Fabricate(:fixity_check, 
        success: false, 
        fixity_at: 3.minutes.ago, 
        created_at: 1.minute.ago)
      other_record = Fabricate(:fixity_check, 
        success: true,
        fixity_at: 3.seconds.ago,
        created_at: 1.second.ago)
      expect(record.update(field => other_record.send(field))).to be false
    end
  end
  
  describe "fixity_check_id" do
    it "is unique" do
      r = Fabricate(:fixity_check)
      expect(Fabricate.build(:fixity_check, fixity_check_id: r.fixity_check_id)).to_not be_valid
    end
    it "is a uuidv4" do
      expect(Fabricate.build(:fixity_check, fixity_check_id: SecureRandom.uuid)).to be_valid
      expect(Fabricate.build(:fixity_check, fixity_check_id: Faker::Lorem.word)).to_not be_valid
    end
  end

  it "requires fixity_at <= created_at" do
    now = Time.now
    expect(Fabricate.build(:fixity_check, fixity_at: 2.minutes.ago, created_at: 1.minute.ago)).to be_valid
    expect(Fabricate.build(:fixity_check, fixity_at: now, created_at: now)).to be_valid
    expect(Fabricate.build(:fixity_check, fixity_at: 1.minute.ago, created_at: 2.minute.ago)).to_not be_valid
  end

  it_behaves_like "it has temporal scopes for", :created_at

  describe "scope latest_only", :broken_in_ci do
    before(:each) do
      @bag1, @bag2 = Fabricate.times(2, :bag)
      @node1, @node2 = Fabricate.times(2, :node)
      @latest_b1_n1 = Fabricate(:fixity_check, bag: @bag1, node: @node1,
        created_at: 1.hour.ago, fixity_at: 2.hours.ago)
      Fabricate(:fixity_check, bag: @bag1, node: @node1,
        created_at: 2.days.ago, fixity_at: 3.days.ago)
      @latest_b2_n1 = Fabricate(:fixity_check, bag: @bag2, node: @node1,
        created_at: 1.hour.ago, fixity_at: 2.hours.ago)
      Fabricate(:fixity_check, bag: @bag2, node: @node1,
        created_at: 2.days.ago, fixity_at: 3.days.ago)
      @latest_b1_n2 = Fabricate(:fixity_check, bag: @bag1, node: @node2,
        created_at: 1.hour.ago, fixity_at: 2.hours.ago)
      Fabricate(:fixity_check, bag: @bag1, node: @node2,
        created_at: 2.days.ago, fixity_at: 3.days.ago)
    end

    it "returns latest for each bag+node pair" do
      expect(FixityCheck.latest_only(true))
        .to contain_exactly @latest_b1_n1, @latest_b1_n2, @latest_b2_n1
    end

    it "returns latest for each node for specified bag" do
      expect(FixityCheck.where(bag_id: @bag1.id).latest_only(true))
        .to contain_exactly @latest_b1_n1, @latest_b1_n2
    end

    it "returns latest for each bag for specified node" do
      expect(FixityCheck.where(node_id: @node1.id).latest_only(true))
        .to contain_exactly @latest_b1_n1, @latest_b2_n1
    end

    it "returns latest for specified bag, node pair" do
      expect(FixityCheck.where(node_id: @node1.id).where(bag_id: @bag1.id).latest_only(true))
        .to contain_exactly @latest_b1_n1
    end

  end
  
end