Fabricator(:replication_status) do
  name "somereplstatus"
  initialize_with { ReplicationStatus.find_or_create_by(name: name)}
end