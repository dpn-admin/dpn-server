Fabricator(:restore_status) do
  name "somerestorestatus"
  initialize_with { RestoreStatus.find_or_create_by(name: name)}
end