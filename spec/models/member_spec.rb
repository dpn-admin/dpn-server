# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Member do
  it "has a valid factory" do
    expect(Fabricate.build(:member)).to be_valid
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
end
