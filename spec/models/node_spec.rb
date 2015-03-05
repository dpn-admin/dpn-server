require 'rails_helper'

describe Node do
  it "has a valid factory" do
    expect(create(:node)).to be_valid
  end

  it "has a storage region" do
    node = build(:node)
    storage_region = node.storage_region

    expect(storage_region).to_not be_nil
  end

  it "has a storage type" do
    node = build(:node)
    storage_type = node.storage_type

    expect(storage_type).to_not be_nil
  end

  it "is invalid without a namespace" do
    expect {
      create(:node, namespace: nil)
    }.to raise_error
  end

  it "stores namespace as lowercase" do
    namespace = "saDFjDF"
    create(:node, namespace: namespace)

    instance = Node.where(namespace: namespace.downcase).first

    expect(instance).to be_valid
    expect(instance.namespace).to eql(namespace.downcase)
  end

  it "can be found when we search with uppercase" do
    namespace = "somenamespace"
    create(:node, namespace: namespace)

    instance = Node.find_by_namespace(namespace.upcase)

    expect(instance).to be_valid
  end
end