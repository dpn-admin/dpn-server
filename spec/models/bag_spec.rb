require 'rails_helper'

describe Bag do
  it "has a valid factory" do
    expect(Fabricate(:bag)).to be_valid
  end
end