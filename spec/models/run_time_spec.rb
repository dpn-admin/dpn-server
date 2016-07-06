# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe RunTime do
  it "has a valid factory" do
    expect(Fabricate(:run_time)).to be_valid
  end

  it "is invalid without a name" do
    expect(Fabricate.build(:run_time, name: nil)).to_not be_valid
  end

  it "requires the names to be unique" do
    Fabricate(:run_time, name: "some_name")
    expect { 
      Fabricate(:run_time, name: "some_name")
    }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken")
  end
  
  it "populates last_success with epoch" do
    expect(Fabricate.build(:run_time, last_success: nil).last_success).to eql(Time.at(0))
  end
  

end