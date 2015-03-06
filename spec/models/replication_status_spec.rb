require 'rails_helper'

describe ReplicationStatus do
  it "has a valid factory" do
    expect(Fabricate(:replication_status)).to be_valid
  end

  it "is invalid without a name" do
    expect {
      Fabricate(:replication_status, name: nil)
    }.to raise_error
  end

  it "can find records" do
    name = "herp"
    Fabricate(:replication_status, name: name)

    instance = ReplicationStatus.where(name: name).first

    expect(instance).to be_valid
  end

  it "should store name as lowercase" do
    name  = "aSDFdsfadsSDFsd"
    Fabricate(:replication_status, name: name)

    instance = ReplicationStatus.where(name: name.downcase).first

    expect(instance).to be_valid
    expect(instance.name).to eql(name.downcase)
  end

  it "can be found when we search with uppercase" do
    name = "somename"
    Fabricate(:replication_status, name: name)

    instance = ReplicationStatus.find_by_name(name.upcase)

    expect(instance).to be_valid
  end
end