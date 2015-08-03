# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe InterpretiveBag do
  it "has a valid factory" do
    expect(Fabricate(:interpretive_bag)).to be_valid
  end
end