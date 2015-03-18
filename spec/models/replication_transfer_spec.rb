require 'rails_helper'

describe ReplicationTransfer do
  it "has a valid factory" do
    expect(Fabricate(:replication_transfer)).to be_valid
  end
end