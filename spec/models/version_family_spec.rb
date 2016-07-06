# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe VersionFamily do
  it "has a valid factory" do
    expect(Fabricate(:version_family)).to be_valid
  end

  describe "::find_fields" do
    it "returns its find fields" do
      expect(VersionFamily.find_fields).to eql(Set.new([:uuid]))
    end
  end

  it "is invalid without a uuid" do
    expect {
      Fabricate(:version_family, uuid: nil)
    }.to raise_error
  end

  it "can be found when" do
    uuid = "f47ac10b-58cc-4372-a567-0e02b2c3d479"
    Fabricate(:version_family, uuid: uuid)
    expect(VersionFamily.find_by_uuid(uuid)).to be_valid
  end

end