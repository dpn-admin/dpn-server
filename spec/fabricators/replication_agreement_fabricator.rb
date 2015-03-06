Fabricator(:replication_agreement) do
  from_node { Fabricate(:node, namespace: "some_from_node") }
  to_node { Fabricate(:node, namespace: "some_to_node") }
end