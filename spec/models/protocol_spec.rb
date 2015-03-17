require 'rails_helper'

describe Protocol do
  it "has a valid factory" do
    expect(Fabricate(:protocol)).to be_valid
  end

  it "is invalid without a name" do
    expect {
      Fabricate(:protocol, name: nil)
    }.to raise_error(ActiveRecord::StatementInvalid)
  end

  it "can find records" do
    name = "herp"
    Fabricate(:protocol, name: name)

    instance = Protocol.where(name: name).first

    expect(instance).to be_valid
  end

  it "should store name as lowercase" do
    name  = "aSDFdsfadsSDFsd"
    Fabricate(:protocol, name: name)

    instance = Protocol.where(name: name.downcase).first

    expect(instance).to be_valid
    expect(instance.name).to eql(name.downcase)
  end

  it "can be found when we search with uppercase" do
    name = "somename"
    Fabricate(:protocol, name: name)

    instance = Protocol.find_by_name(name.upcase)

    expect(instance).to be_valid
  end
end