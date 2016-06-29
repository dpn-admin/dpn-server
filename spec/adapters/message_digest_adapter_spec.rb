# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe MessageDigestAdapter do
  uuid = SecureRandom.uuid
  fixity_alg_name = "fake_fixity_alg_name"
  value = SecureRandom.uuid
  node_namespace = "fake_namespace"

  before(:each) do
    @model = Fabricate(:message_digest,
      bag: Fabricate(:data_bag, uuid: uuid),
      fixity_alg: Fabricate(:fixity_alg, name: fixity_alg_name),
      value: value,
      node: Fabricate(:node, namespace: node_namespace),
      created_at: time_from_string("2015-02-25T15:27:40Z")
    )
    @model.save!


    @public_hash = {
      bag: uuid,
      node: node_namespace,
      algorithm: fixity_alg_name,
      value: value,
      created_at: "2015-02-25T15:27:40Z"
    }

    @model_hash = {
      bag_id: @model.bag_id,
      node_id: @model.node_id,
      fixity_alg_id: @model.fixity_alg_id,
      value: value,
      created_at: time_from_string("2015-02-25T15:27:40Z")
    }

  end

  let(:model) { @model }
  let(:public_hash) { @public_hash }
  let(:model_hash) { @model_hash }

  it_behaves_like "an adapter"

end