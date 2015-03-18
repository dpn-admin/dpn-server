require 'rails_helper'

describe InterpretiveBag do
  it "has a valid factory" do
    expect(Fabricate(:interpretive_bag)).to be_valid
  end
end