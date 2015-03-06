Fabricator(:node) do
  namespace "test"
  name "Some Readable Name"
  ssh_pubkey "somepublickey"
  storage_region
  storage_type
end