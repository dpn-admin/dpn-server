# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe FrequentApple::RunTime, type: :model do
  it "has a valid factory" do
    expect(Fabricate(:frequent_apple_run_time)).to be_valid
  end

  it "defaults to run_time=epoch" do
    m = Fabricate(:frequent_apple_run_time, last_run_time: nil)
    expect(m.last_run_time).to eql(Time.at(0))
  end

  it "does not override a time on retrieval" do
    now = Time.now
    m = Fabricate(:frequent_apple_run_time, last_run_time: now)
    expect(FrequentApple::RunTime.find(m.id).last_run_time.utc.iso8601).to eql(now.utc.iso8601)
  end

  it "is invalid without a namespace" do
    expect(Fabricate.build(:frequent_apple_run_time, namespace: nil)).to_not be_valid
  end

end
