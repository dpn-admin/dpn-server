Fabricator(:replication_agreement) do
  from_node { Fabricate(:node, namespace: "some_from_node") }
  to_node { Fabricate(:node, namespace: "some_to_node") }
  initialize_with { ReplicationAgreement.find_or_create_by(from_node: from_node, to_node: to_node) }
end