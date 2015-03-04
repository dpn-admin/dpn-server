require 'rails_helper'

describe StorageType do
  it "has a valid factory" do
    expect(create(:storage_type)).to be_valid
  end

  it "is invalid without a name" do
    expect {
      create(:storage_type, name: nil)
    }.to raise_error
  end

  it "can find records" do
    name = "herp"
    create(:storage_type, name: name)

    instance = StorageType.where(name: name).first

    expect(instance).to be_valid
  end

  it "should store name as lowercase" do
    name  = "aSDFdsfadsSDFsd"
    create(:storage_type, name: name)

    instance = StorageType.where(name: name.downcase).first

    expect(instance).to be_valid
    expect(instance.name).to eql(name.downcase)
  end
end