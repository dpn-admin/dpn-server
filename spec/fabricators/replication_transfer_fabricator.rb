# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:replication_transfer) do
  bag_valid nil
  fixity_value nil
  fixity_accept nil

  status :requested
  created_at 1.month.ago
  updated_at 1.month.ago

  bag { Fabricate(:bag) }
  link { Faker::Internet.url }
  to_node { Fabricate(:node) }
  from_node { Fabricate(:node) }
  protocol { Fabricate(:protocol) }
  replication_id { SecureRandom.uuid }
  fixity_alg { Fabricate(:fixity_alg) }
  fixity_nonce { Faker::Internet.password(6) }
end

Fabricator(:replication_transfer_requested, from: :replication_transfer) do
  status :requested
end

Fabricator(:replication_transfer_rejected, from: :replication_transfer) do
  status :rejected
  after_build { |record|
    Fabricate(:bag_man_request, status: :rejected, replication_transfer: record)
  }
end

Fabricator(:replication_transfer_received_nil, from: :replication_transfer) do
  status :received

  after_build { |replication_transfer, transients|
    fixity_alg = bag.fixity_checks[0].fixity_alg
    replication_transfer.update(fixity_alg: fixity_alg)
  }
end

Fabricator(:replication_transfer_received, from: :replication_transfer) do
  status :received
  fixity_value { Faker::Internet.password(20) }
  bag_valid true
  after_build do |record|
    Fabricate(:bag_man_request,
      fixity: Faker::Internet.password(20),
      validity: true,
      status: :unpacked,
      replication_transfer: record)
  end
end

Fabricator(:replication_transfer_confirmed, from: :replication_transfer) do
  status :confirmed
  fixity_value { Faker::Internet.password(20) }
  bag_valid true
  fixity_accept true
  after_build do |record|
    Fabricate(:bag_man_request,
      fixity: Faker::Internet.password(20),
      validity: true,
      status: :unpacked,
      replication_transfer: record)
  end
end

Fabricator(:replication_transfer_stored, from: :replication_transfer) do
  status :stored
  fixity_value { Faker::Internet.password(20) }
  bag_valid true
  fixity_accept true
  after_build do |record|
    Fabricate(:bag_man_request,
      fixity: Faker::Internet.password(20),
      validity: true,
      status: :preserved,
      replication_transfer: record)
  end
end

Fabricator(:replication_transfer_cancelled, from: :replication_transfer) do
  status :cancelled
end
