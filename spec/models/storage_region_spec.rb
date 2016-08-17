# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe StorageRegion do
  it "has a valid factory" do
    expect(Fabricate(:storage_region)).to be_valid
  end

  describe "::find_fields" do
    it "returns its find fields" do
      expect(StorageRegion.find_fields).to eql(Set.new([:name]))
    end
  end

  it "is invalid without a name" do
    expect(Fabricate.build(:storage_region, name: nil)).to_not be_valid
  end

  it "can find records" do
    name = "herp"
    Fabricate(:storage_region, name: name)

    instance = StorageRegion.where(name: name).first

    expect(instance).to be_valid
  end

  it "should store name as lowercase" do
    name  = "aSDFdsfadsSDFsd"
    Fabricate(:storage_region, name: name)

    instance = StorageRegion.where(name: name.downcase).first

    expect(instance).to be_valid
    expect(instance.name).to eql(name.downcase)
  end

  it "can be found when we search with uppercase" do
    name = "somename"
    Fabricate(:storage_region, name: name)

    instance = StorageRegion.find_by_name(name.upcase)

    expect(instance).to be_valid
  end
end