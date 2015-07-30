require 'rails_helper'

describe ReplicationTransfer do
  it "has a valid factory" do
    expect(Fabricate(:replication_transfer)).to be_valid
  end

  it "requires a replication_id" do
    instance = Fabricate(:replication_transfer)
    instance.replication_id = nil
    expect(instance).to_not be_valid
  end

end