Fabricator(:bag) do
  uuid { SecureRandom.uuid }
  local_id { Faker::Bitcoin.address }
  size { Faker::Number.number(12) }
  version 1
  version_family
  ingest_node { Fabricate(:node) }
  admin_node { Fabricate(:node) }
end