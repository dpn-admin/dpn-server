Fabricator(:storage_type) do
  name "sometype"
  initialize_with { StorageType.find_or_create_by(name: name)}
end