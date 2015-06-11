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

  it "returns the source location" do
    request = Fabricate(:bag_manager_request)
    staging_dir = "/herpderp"
    expected = File.join staging_dir, request.id.to_s, File.basename(request.source_location)
    expect(request.staging_location(staging_dir)).to eql(expected)
  end

  # Todo: put a lot more validations on the states that can
  # be held here.
end
