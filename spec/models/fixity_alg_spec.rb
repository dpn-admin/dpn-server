# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe FixityAlg do
  it "has a valid factory" do
    expect(Fabricate.build(:fixity_alg)).to be_valid
  end

  it "is invalid without a name" do
    expect(Fabricate.build(:fixity_alg, name: nil)).to_not be_valid
  end

  describe "::find_fields" do
    it "returns its find fields" do
      expect(FixityAlg.find_fields).to eql(Set.new([:name]))
    end
  end

  it "can find records" do
    name = "derp"
    Fabricate(:fixity_alg, name: name)

    instance = FixityAlg.where(name: name).first

    expect(instance).to be_valid
  end

  it "should store name as lowercase" do
    name = "DsfDSFsdasdfDSF"
    Fabricate(:fixity_alg, name: name)

    instance = FixityAlg.where(name: name.downcase).first

    expect(instance).to be_valid
    expect(instance.name).to eql(name.downcase)
  end

  it "can be found when we search with uppercase" do
    name = "somename"
    Fabricate(:fixity_alg, name: name)

    instance = FixityAlg.find_by_name(name.upcase)

    expect(instance).to be_valid
  end
end