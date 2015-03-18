Fabricator(:replication_agreement) do
  from_node { Fabricate(:node) }
  to_node { Fabricate(:node) }
end