# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe ReplicationAgreement do
  it "has a valid factory" do
    expect(Fabricate(:replication_agreement)).to be_valid
  end

  it "has a valid from_node" do
    from_node = Fabricate.build(:replication_agreement).from_node
    expect(from_node).to be_valid
  end

  it "has a valid to_node" do
    to_node = Fabricate.build(:replication_agreement).to_node
    expect(to_node).to be_valid
  end

  it "is invalid without a from_node" do
    expect(Fabricate.build(:replication_agreement, from_node: nil)).to_not be_valid
  end

  it "is invalid without a to_node" do
    expect(Fabricate.build(:replication_agreement, to_node: nil)).to_not be_valid
  end

end