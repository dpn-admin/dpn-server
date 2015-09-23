# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:replication_transfer) do
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
  bag_man_request_id nil
end

Fabricator(:replication_transfer_requested, from: :replication_transfer) do
  replication_status { ReplicationStatus.find_or_create_by(name: "requested")}
end

Fabricator(:replication_transfer_rejected, from: :replication_transfer) do
  replication_status { ReplicationStatus.find_or_create_by(name: "rejected")}
  bag_man_request_id { Fabricate(:bag_man_request, status: :rejected).id }
end

Fabricator(:replication_transfer_received, from: :replication_transfer) do
  replication_status { ReplicationStatus.find_or_create_by(name: "received")}
  fixity_value { Faker::Internet.password(20) }
  bag_valid true
  bag_man_request_id { Fabricate(:bag_man_request,
                                 fixity: Faker::Internet.password(20),
                                 validity: true,
                                 status: :unpacked).id }
end

Fabricator(:replication_transfer_confirmed, from: :replication_transfer) do
  replication_status { ReplicationStatus.find_or_create_by(name: "confirmed")}
  fixity_value { Faker::Internet.password(20) }
  bag_valid true
  fixity_accept true
  bag_man_request_id { Fabricate(:bag_man_request,
                                 fixity: Faker::Internet.password(20),
                                 validity: true,
                                 status: :unpacked).id }
end

Fabricator(:replication_transfer_stored, from: :replication_transfer) do
  replication_status { ReplicationStatus.find_or_create_by(name: "stored")}
  fixity_value { Faker::Internet.password(20) }
  bag_valid true
  fixity_accept true
  bag_man_request_id { Fabricate(:bag_man_request,
                                 fixity: Faker::Internet.password(20),
                                 validity: true,
                                 status: :preserved).id }
end

Fabricator(:replication_transfer_cancelled, from: :replication_transfer) do
  replication_status { ReplicationStatus.find_or_create_by(name: "cancelled")}
end
