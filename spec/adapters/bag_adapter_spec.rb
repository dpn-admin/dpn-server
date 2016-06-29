# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe BagAdapter do
  uuid = SecureRandom.uuid
  rights_uuid = SecureRandom.uuid
  interpretive_uuid = SecureRandom.uuid
  member_uuid = SecureRandom.uuid
  local_id = "our_local_id"
  ingest_node_namespace  = "fake_ingest_node"
  admin_node_namespace = "fake_admin_node"
  repl_node_namespace = "fake_repl_node"

  before(:each) do
    @model = Fabricate(:data_bag,
      uuid: uuid,
      local_id: local_id,
      size: 10101,
      version: 1,
      version_family: Fabricate(:version_family, uuid: uuid),
      ingest_node: Fabricate(:node, namespace: ingest_node_namespace),
      admin_node: Fabricate(:node, namespace: admin_node_namespace),
      member: Fabricate(:member, uuid: member_uuid),
      created_at: time_from_string("2015-02-25T15:27:40Z"),
      updated_at: time_from_string("2015-02-25T15:27:40Z")
    )
    @model.rights_bags = [Fabricate(:rights_bag, uuid: rights_uuid)]
    @model.interpretive_bags = [Fabricate(:interpretive_bag, uuid: interpretive_uuid)]
    @model.replicating_nodes = [Fabricate(:node, namespace: repl_node_namespace)]

    @model.save!

    @public_hash = {
      uuid: uuid,
      ingest_node: ingest_node_namespace,
      interpretive: [interpretive_uuid],
      rights: [rights_uuid],
      replicating_nodes: [repl_node_namespace],
      admin_node: admin_node_namespace,
      member: member_uuid,
      local_id: local_id,
      size: 10101,
      first_version_uuid: uuid,
      version: 1,
      bag_type: "D",
      created_at: "2015-02-25T15:27:40Z",
      updated_at: "2015-02-25T15:27:40Z"
    }

    @model_hash = {
      uuid: uuid,
      local_id: local_id,
      size: 10101,
      version: 1,
      version_family: @model.version_family,
      ingest_node_id: @model.ingest_node_id,
      admin_node_id: @model.admin_node_id,
      member_id: @model.member_id,
      created_at: time_from_string("2015-02-25T15:27:40Z"),
      updated_at: time_from_string("2015-02-25T15:27:40Z"),
      interpretive_bags: @model.interpretive_bags,
      rights_bags: @model.rights_bags,
      replicating_nodes: @model.replicating_nodes,
      type: "DataBag"
    }
  end

  let(:model) { @model }
  let(:public_hash) { @public_hash }
  let(:model_hash) { @model_hash }

  it_behaves_like "an adapter"

end