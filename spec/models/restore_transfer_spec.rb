require 'rails_helper'

describe RestoreTransfer do
  it "has a valid factory" do
    expect(Fabricate(:restore_transfer)).to be_valid
  end
end