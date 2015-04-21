Fabricator(:replication_transfer) do
  replication_id { Faker::Internet.password(7) }
  bag { Fabricate(:bag) }
  from_node { Fabricate(:node) }
  to_node { Fabricate(:node) }
  replication_status { Fabricate(:replication_status) }
  protocol { Fabricate(:protocol) }
  link { Faker::Internet.url }
  bag_valid nil
  fixity_alg { Fabricate(:fixity_alg) }
  fixity_nonce { Faker::Internet.password(6) }
  fixity_value nil
  fixity_accept nil
end

Fabricator(:replication_transfer_requested, from: :replication_transfer) do
  replication_status { ReplicationStatus.find_or_create_by(name: "requested")}
end

Fabricator(:replication_transfer_rejected, from: :replication_transfer) do
  replication_status { ReplicationStatus.find_or_create_by(name: "rejected")}
end

Fabricator(:replication_transfer_received, from: :replication_transfer) do
  replication_status { ReplicationStatus.find_or_create_by(name: "received")}
  fixity_value { Faker::Internet.password(20) }
  bag_valid true
end

Fabricator(:replication_transfer_confirmed, from: :replication_transfer) do
  replication_status { ReplicationStatus.find_or_create_by(name: "confirmed")}
  fixity_value { Faker::Internet.password(20) }
  bag_valid true
  fixity_accept true
end

Fabricator(:replication_transfer_stored, from: :replication_transfer) do
  replication_status { ReplicationStatus.find_or_create_by(name: "stored")}
  fixity_value { Faker::Internet.password(20) }
  bag_valid true
  fixity_accept true
end

Fabricator(:replication_transfer_cancelled, from: :replication_transfer) do
  replication_status { ReplicationStatus.find_or_create_by(name: "cancelled")}
end
