require 'rails_helper'

describe RestoreTransfer do
  it "has a valid factory" do
    expect(Fabricate(:restore_transfer)).to be_valid
  end

  it "requires a restore_id" do
    instance = Fabricate(:restore_transfer)
    instance.restore_id = nil
    expect(instance).to_not be_valid
  end
end