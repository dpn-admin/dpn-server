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