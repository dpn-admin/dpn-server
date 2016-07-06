# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe RightsBag do
  it "has a valid factory" do
    expect(Fabricate(:rights_bag)).to be_valid
  end

  it "has a factory that honors updated_at" do
    time = 1.year.ago
    record = Fabricate(:rights_bag, updated_at: 1.year.ago)
    expect(record.updated_at.change(usec: 0)).to eql time.change(usec: 0)
  end

  describe "::find_fields" do
    it "returns its find fields" do
      expect(Bag.find_fields).to eql(Set.new([:uuid]))
    end
  end
end