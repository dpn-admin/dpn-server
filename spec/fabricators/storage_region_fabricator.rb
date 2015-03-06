Fabricator(:storage_region) do
  name "someregion"
  initialize_with { StorageRegion.find_or_create_by(name: name)}
end