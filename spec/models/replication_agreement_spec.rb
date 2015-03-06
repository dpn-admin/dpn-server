require 'rails_helper'

describe ReplicationAgreement do
  it "has a valid factory" do
    expect(Fabricate(:replication_agreement)).to be_valid
  end

  it "has a valid factory if I handhold it" do
    from_node = Fabricate(:node, namespace: "some_from_node")
    to_node = Fabricate(:node, namespace: "some_to_node")

    ra = Fabricate(:replication_agreement, from_node: from_node, to_node: to_node)

    expect(ra).to be_valid

  end
end