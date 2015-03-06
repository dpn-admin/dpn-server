Fabricator(:version_family) do
  uuid "f47ac10b58cc4372a5670e02b2c3d479"
  initialize_with { VersionFamily.find_or_create_by(uuid: uuid)}
end