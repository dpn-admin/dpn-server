Fabricator(:protocol) do
  name "protocol"
  initialize_with { Protocol.find_or_create_by(name: name)}
end