require 'rails_helper'

describe DataBag do
  it "has a valid factory" do
    expect(Fabricate(:data_bag)).to be_valid
  end
end