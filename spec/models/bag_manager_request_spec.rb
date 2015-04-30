require 'rails_helper'

describe BagManagerRequest, type: :model do
  it "has a valid factory" do
    expect(Fabricate(:bag_manager_request)).to be_valid
  end

  it "is invalid without a source_location" do
    expect {
      Fabricate(:bag_manager_request, source_location: nil)
    }.to raise_error(ActiveRecord::ActiveRecordError)
  end

  # Todo: put a lot more validations on the states that can
  # be held here.

  # context "complete is true" do
  #   it "cannot be set to false" do
  #     record = Fabricate(:bag_manager_request, complete: true)
  #     record.complete = false
  #     expect(record.valid?).to eql(false)
  #   end
  # end
end
