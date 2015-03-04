require 'rails_helper'

describe VersionFamily do
  it "has a valid factory" do
    expect(create(:version_family)).to be_valid
  end

  it "is invalid without a uuid" do
    expect {
      create(:version_family, uuid: nil)
    }.to raise_error
  end

  it "adds dashes when reading" do
    instance = build(:version_family, uuid: "f47ac10b58cc4372a5670e02b2c3d479")
    expect(instance.uuid).to match(/\A[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12}\Z/)
  end

  it "removes dashes when saving" do
    uuid = "f47ac10b-58cc-4372-a567-0e02b2c3d479"
    create(:version_family, uuid: uuid)

    instance = VersionFamily.find_by_sql(["SELECT * FROM version_families WHERE uuid = ?", uuid.delete('-')]).first

    expect(instance).to be_valid
  end

  it "can be found when we include dashes" do
    uuid = "f47ac10b-58cc-4372-a567-0e02b2c3d479"
    create(:version_family, uuid: uuid.delete('-'))

    instance = VersionFamily.find_by_uuid(uuid)

    expect(instance).to be_valid
  end

  it "can be found when we don't include dashes" do
    dashless_uuid = "f47ac10b-58cc-4372-a567-0e02b2c3d479".delete('-')
    create(:version_family, uuid: dashless_uuid)

    instance = VersionFamily.find_by_uuid(dashless_uuid)

    expect(instance).to be_valid
  end

end