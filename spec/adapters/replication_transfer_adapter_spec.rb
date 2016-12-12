# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe ReplicationTransferAdapter do
  replication_id = SecureRandom.uuid
  from_node_namespace = "fake_from_node"
  to_node_namespace = "fake_to_node"
  uuid = SecureRandom.uuid
  fixity_algorithm_name = "fake_fixity_alg"
  fixity_value = SecureRandom.uuid.delete("-")
  protocol_name = "fake_protocol"
  updated_at = "2015-02-25T15:27:40Z"
  created_at = "2015-02-25T15:27:40Z"
  link = "user@herp.derp.org:/blah"
  cancel_reason_detail = "testing is fun # comment // woo"


  before(:each) do

    @model = Fabricate(:replication_transfer,
      replication_id: replication_id,
      from_node: Fabricate(:node, namespace: from_node_namespace),
      to_node: Fabricate(:node, namespace: to_node_namespace),
      bag: Fabricate(:data_bag, uuid: uuid),
      protocol: Fabricate(:protocol, name: protocol_name),
      link: link,
      fixity_alg: Fabricate(:fixity_alg, name: fixity_algorithm_name),
      fixity_nonce: nil,
      fixity_value: fixity_value,
      store_requested: true,
      stored: false,
      cancelled: true,
      cancel_reason_detail: cancel_reason_detail,
      cancel_reason: 'other',
      created_at: time_from_string(created_at),
      updated_at: time_from_string(updated_at)
    )

    @public_hash = {
      replication_id: replication_id,
      from_node: from_node_namespace,
      to_node: to_node_namespace,
      bag: uuid,
      fixity_algorithm: fixity_algorithm_name,
      fixity_nonce: nil,
      fixity_value: fixity_value,
      store_requested: true,
      stored: false,
      cancelled: true,
      cancel_reason: 'other',
      cancel_reason_detail: cancel_reason_detail,
      protocol: protocol_name,
      link: link,
      created_at: created_at,
      updated_at: updated_at
    }

    @model_hash = {
      replication_id: replication_id,
      from_node: @model.from_node,
      to_node: @model.to_node,
      bag: @model.bag,
      protocol: @model.protocol,
      link: link,
      fixity_alg: @model.fixity_alg,
      fixity_nonce: nil,
      fixity_value: fixity_value,
      store_requested: true,
      stored: false,
      cancelled: true,
      cancel_reason: 'other',
      cancel_reason_detail: cancel_reason_detail,
      created_at: time_from_string(created_at),
      updated_at: time_from_string(updated_at)
    }
  end

  let(:model) { @model }
  let(:public_hash) { @public_hash }
  let(:model_hash) { @model_hash }

  it_behaves_like "an adapter"

end

