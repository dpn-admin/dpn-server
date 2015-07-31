require 'rails_helper'

describe VersionFamily do
  it "has a valid factory" do
    expect(Fabricate(:version_family)).to be_valid
  end

  it "is invalid without a uuid" do
    expect {
      Fabricate(:version_family, uuid: nil)
    }.to raise_error
  end

  it "can be found when" do
    uuid = "f47ac10b-58cc-4372-a567-0e02b2c3d479"
    Fabricate(:version_family, uuid: uuid)
    expect(VersionFamily.find_by_uuid(uuid)).to be_valid
  end

end