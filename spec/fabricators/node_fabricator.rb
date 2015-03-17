Fabricator(:node) do
  namespace "sdgsdfgsgsdg"
  name "Some Readable Name"
  ssh_pubkey "somepublickey"
  storage_region
  storage_type

  initialize_with {
    Node.find_or_create_by(
      namespace: namespace,
      name: name,
      ssh_pubkey: ssh_pubkey,
      storage_region: storage_region,
      storage_type: storage_type
    )
  }

end