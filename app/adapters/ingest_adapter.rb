# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class IngestAdapter < ::AbstractAdapter
  map_date :created_at, :created_at

  map_simple      :ingest_id, :ingest_id
  map_belongs_to  :bag,       :bag,       sub_method: :uuid
  map_bool        :ingested,  :ingested
  map_has_many :nodes, :replicating_nodes, model_class: Node, sub_method: :namespace
end
