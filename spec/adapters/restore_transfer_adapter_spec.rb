# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe RestoreTransferAdapter do
  before(:each) do
    @model = Fabricate(:restore_transfer,
      restore_id: "f107347c-81ea-4c6f-a508-a90d4b797497",
      from_node: Fabricate(:node, namespace: "fake_from_node"),
      to_node: Fabricate(:node, namespace: "fake_to_node"),
      bag: Fabricate(:data_bag, uuid: "9c0d880f-058c-4240-a71f-7048be13f448"),
      protocol: Fabricate(:protocol, name: "fake_transfer_protocol"),
      link: "user@herp.derp.org:/blah",
      status: :prepared,
      created_at: "2015-02-25T15:27:40Z",
      updated_at: "2015-02-25T15:27:40Z"
    )

    @public_hash = {
      restore_id: "f107347c-81ea-4c6f-a508-a90d4b797497",
      from_node: "fake_from_node",
      to_node: "fake_to_node",
      bag: "9c0d880f-058c-4240-a71f-7048be13f448",
      protocol: "fake_transfer_protocol",
      link: "user@herp.derp.org:/blah",
      status: "prepared",
      created_at: "2015-02-25T15:27:40Z",
      updated_at: "2015-02-25T15:27:40Z"
    }

    @model_hash = {
      restore_id: "f107347c-81ea-4c6f-a508-a90d4b797497",
      from_node_id: @model.from_node_id,
      to_node_id: @model.to_node_id,
      bag_id: @model.bag_id,
      protocol_id: @model.protocol_id,
      link: "user@herp.derp.org:/blah",
      status: "prepared",
      created_at: time_from_string("2015-02-25T15:27:40Z"),
      updated_at: time_from_string("2015-02-25T15:27:40Z")
    }
  end

  let(:model) { @model }
  let(:public_hash) { @public_hash }
  let(:model_hash) { @model_hash }

  it_behaves_like "an adapter"

end

