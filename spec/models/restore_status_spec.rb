# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe RestoreStatus do
  it "has a valid factory" do
    expect(Fabricate(:restore_status)).to be_valid
  end

  it "is invalid without a name" do
    expect {
      Fabricate(:restore_status, name: nil)
    }.to raise_error
  end

  it "can find records" do
    name = "herp"
    Fabricate(:restore_status, name: name)

    instance = RestoreStatus.where(name: name).first

    expect(instance).to be_valid
  end

  it "should store name as lowercase" do
    name  = "aSDFdsfadsSDFsd"
    Fabricate(:restore_status, name: name)

    instance = RestoreStatus.where(name: name.downcase).first

    expect(instance).to be_valid
    expect(instance.name).to eql(name.downcase)
  end

  it "can be found when we search with uppercase" do
    name = "somename"
    Fabricate(:restore_status, name: name)

    instance = RestoreStatus.find_by_name(name.upcase)

    expect(instance).to be_valid
  end

end