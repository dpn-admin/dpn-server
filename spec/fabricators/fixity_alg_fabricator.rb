Fabricator(:fixity_alg) do
  name "somefixityalg"
  initialize_with { FixityAlg.find_or_create_by(name: name)}
end