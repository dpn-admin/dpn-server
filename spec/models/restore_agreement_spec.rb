require 'rails_helper'

describe RestoreAgreement do
  it "has a valid factory" do
    expect(Fabricate(:restore_agreement)).to be_valid
  end

  it "has a valid from_node" do
    from_node = Fabricate.build(:restore_agreement).from_node
    expect(from_node).to be_valid
  end

  it "has a valid to_node" do
    to_node = Fabricate.build(:restore_agreement).to_node
    expect(to_node).to be_valid
  end

  it "is invalid without a from_node" do
    expect {
      Fabricate(:restore_agreement, from_node: nil)
    }.to raise_error(ActiveRecord::ActiveRecordError)
  end

  it "is invalid without a to_node" do
    expect {
      Fabricate(:restore_agreement, to_node: nil)
    }.to raise_error(ActiveRecord::ActiveRecordError)
  end

end