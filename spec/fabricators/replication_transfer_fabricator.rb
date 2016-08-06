# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:replication_transfer) do
  fixity_value nil
  store_requested false
  stored false
  cancelled false
  cancel_reason nil

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


Fabricator(:replication_transfer_rejected, from: :replication_transfer) do
  cancelled true
  cancel_reason 'reject'
  after_build { |record|
    Fabricate(:bag_man_request, status: :rejected, replication_transfer: record)
  }
end


Fabricator(:replication_transfer_with_fixity_value, from: :replication_transfer) do
  fixity_value { Faker::Internet.password(20) }
  after_build do |record|
    Fabricate(:bag_man_request,
      fixity: Faker::Internet.password(20),
      validity: true,
      status: :unpacked,
      replication_transfer: record)
  end
end


Fabricator(:replication_transfer_with_store_requested, from: :replication_transfer_with_fixity_value) do
  store_requested true
end

Fabricator(:replication_transfer_with_stored, from: :replication_transfer) do
  store_requested true
  fixity_value { Faker::Internet.password(20) }
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
