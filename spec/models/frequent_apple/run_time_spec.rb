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

end
