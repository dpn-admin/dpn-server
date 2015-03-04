require 'rails_helper'

describe RestoreStatus do
  it "has a valid factory" do
    expect(create(:restore_status)).to be_valid
  end

  it "is invalid without a name" do
    expect {
      create(:restore_status, name: nil)
    }.to raise_error
  end

  it "can find records" do
    name = "herp"
    create(:restore_status, name: name)

    instance = RestoreStatus.where(name: name).first

    expect(instance).to be_valid
  end

  it "should store name as lowercase" do
    name  = "aSDFdsfadsSDFsd"
    create(:restore_status, name: name)

    instance = RestoreStatus.where(name: name.downcase).first

    expect(instance).to be_valid
    expect(instance.name).to eql(name.downcase)
  end

end