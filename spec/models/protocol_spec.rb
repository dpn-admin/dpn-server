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

  # it "should ignore case when searching" do
  #   name = "herp"
  #   create(:protocol, name: name.downcase)
  #
  #   instance = Protocol.where(name: name.upcase).first
  #
  #   expect(instance).to be_valid
  # end
end