require 'rails_helper'

describe RightsBag do
  it "has a valid factory" do
    expect(Fabricate(:rights_bag)).to be_valid
  end
end