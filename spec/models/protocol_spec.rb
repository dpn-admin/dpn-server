require 'rails_helper'

describe Protocol do
  it "has a valid factory" do
    expect(create(:protocol)).to be_valid
  end

  it "is invalid without a name" do
    expect {
      create(:protocol, name: nil)
    }.to raise_error
  end

  it "can find records" do
    name = "herp"
    create(:protocol, name: name)

    instance = Protocol.where(name: name).first

    expect(instance).to be_valid
  end

  it "should store name as lowercase" do
    name  = "aSDFdsfadsSDFsd"
    create(:protocol, name: name)

    instance = Protocol.where(name: name.downcase).first

    expect(instance).to be_valid
    expect(instance.name).to eql(name.downcase)
  end

  it "can be found when we search with uppercase" do
    name = "somename"
    create(:protocol, name: name)

    instance = Protocol.find_by_name(name.upcase)

    expect(instance).to be_valid
  end
end