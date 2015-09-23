# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe ReplicationTransfer do
  it "has a valid factory" do
    expect(Fabricate(:replication_transfer)).to be_valid
  end

  it "creates a replication_id" do
    instance = Fabricate(:replication_transfer)
    expect(instance).to be_valid
    expect(instance.replication_id).to_not be_empty
  end

end
