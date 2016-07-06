# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Member do
  it "has a valid factory" do
    expect(Fabricate.build(:member)).to be_valid
  end

  it "has a factory that honors updated_at" do
    time = 1.year.ago
    record = Fabricate(:member, updated_at: 1.year.ago)
    expect(record.updated_at.change(usec: 0)).to eql time.change(usec: 0)
  end

  describe "::find_fields" do
    it "returns its find fields" do
      expect(Member.find_fields).to eql(Set.new([:uuid]))
    end
  end

  describe "uuid" do
    it "is required" do
      expect(Fabricate.build(:member, uuid: nil)).to_not be_valid
    end
    it "disallows changing" do
      member = Fabricate(:member)
      member.uuid = SecureRandom.uuid
      expect(member.save).to be false
    end
    it "only accepts valid uuids" do
      expect(Fabricate.build(:member, uuid: "someuuid")).to_not be_valid
    end
  end

  describe "name" do
    it "is required" do
      expect(Fabricate.build(:member, name: nil)).to_not be_valid
    end
    it "allows changing" do
      member = Fabricate(:member)
      member.name = Faker::Company.name
      expect(member.save).to be true
    end
  end

  describe "email" do
    it "is required" do
      expect(Fabricate.build(:member, email: nil)).to_not be_valid
    end
    it "allows changing" do
      member = Fabricate(:member)
      member.email = Faker::Internet.email
      expect(member.save).to be true
    end
  end

  describe "scope" do
    # Define two distinct entities
    let(:member_a) { Fabricate(:member) }
    let(:member_b) { Fabricate(:member) }

    # Create queries specific to member_a
    let(:members_by_name) { Member.with_name(member_a.name) }
    let(:members_by_email) { Member.with_email(member_a.email) }

    it 'filters based on name' do
      expect(members_by_name).to include(member_a)
      expect(members_by_name).to_not include(member_b)
    end

    it 'filters based on email' do
      expect(members_by_email).to include(member_a)
      expect(members_by_email).to_not include(member_b)
    end
  end
end
