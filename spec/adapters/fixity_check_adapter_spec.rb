# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe FixityCheckAdapter do
  fixity_check_id = SecureRandom.uuid
  uuid = SecureRandom.uuid
  node_namespace = "fake_namespace"

  before(:each) do
    @model = Fabricate(:fixity_check,
      fixity_check_id: fixity_check_id,
      bag: Fabricate(:data_bag, uuid: uuid),
      node: Fabricate(:node, namespace: node_namespace),
      success: true,
      fixity_at: time_from_string("2015-02-25T15:27:40Z"),
      created_at: time_from_string("2015-02-25T15:27:40Z")
    )
    @model.save!


    @public_hash = {
      fixity_check_id: fixity_check_id,
      bag: uuid,
      node: node_namespace,
      success: true,
      fixity_at: "2015-02-25T15:27:40Z",
      created_at: "2015-02-25T15:27:40Z"
    }

    @model_hash = {
      fixity_check_id: fixity_check_id,
      bag_id: @model.bag_id,
      node_id: @model.node_id,
      success: true,
      fixity_at: time_from_string("2015-02-25T15:27:40Z"),
      created_at: time_from_string("2015-02-25T15:27:40Z")
    }

  end

  let(:model) { @model }
  let(:public_hash) { @public_hash }
  let(:model_hash) { @model_hash }

  it_behaves_like "an adapter"

end