require 'rails_helper'

describe StorageRegion do
  it "has a valid factory" do
    expect(create(:storage_region)).to be_valid
  end

  it "is invalid without a name" do
    expect {
      create(:storage_region, name: nil)
    }.to raise_error
  end

  it "can find records" do
    name = "herp"
    create(:storage_region, name: name)

    instance = StorageRegion.where(name: name).first

    expect(instance).to be_valid
  end

  it "should store name as lowercase" do
    name  = "aSDFdsfadsSDFsd"
    create(:storage_region, name: name)

    instance = StorageRegion.where(name: name.downcase).first

    expect(instance).to be_valid
    expect(instance.name).to eql(name.downcase)
  end

  it "can be found when we search with uppercase" do
    name = "somename"
    create(:storage_region, name: name)

    instance = StorageRegion.find_by_name(name.upcase)

    expect(instance).to be_valid
  end
end