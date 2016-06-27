# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe ApiV2::IngestAdapter do
  ingest_id = SecureRandom.uuid
  bag_uuid = SecureRandom.uuid
  ingested = [true,false].sample
  created_at = "2015-02-25T15:27:40Z"
  node_namespace = "foo"

  before(:each) do
    @model = Fabricate(:ingest,
      ingest_id: ingest_id,
      bag: Fabricate(:data_bag, uuid: bag_uuid),
      ingested: ingested,
      nodes: [Fabricate(:node, namespace: node_namespace)],
      created_at: time_from_string(created_at)
    )
    @model.save!
    

    @public_hash = {
      ingest_id: ingest_id,
      bag: bag_uuid,
      ingested: ingested,
      replicating_nodes: [node_namespace],
      created_at: created_at
    }

    @model_hash = {
      ingest_id: ingest_id,
      bag_id: @model.bag_id,
      ingested: ingested,
      nodes: @model.nodes,
      created_at: time_from_string(created_at)
    }

  end

  let(:model) { @model }
  let(:public_hash) { @public_hash }
  let(:model_hash) { @model_hash }
    
  it_behaves_like "an adapter"

end