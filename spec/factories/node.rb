FactoryGirl.define do
  factory :node do |f|
    f.namespace "test"
    f.name "Some Readable Name"
    f.ssh_pubkey "somepublickey"
    association :storage_region, factory: :storage_region
    association :storage_type, factory: :storage_type
  end
end