# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module ApiV1
  class ReplicationTransferAdapter < ::AbstractAdapter
    map_simple :replication_id, :replication_id
    map_simple :fixity_nonce, :fixity_nonce
    map_simple :fixity_value, :fixity_value
    map_simple :fixity_accept, :fixity_accept
    map_simple :bag_valid, :bag_valid
    map_simple :status, :status
    map_simple :link, :link

    map_belongs_to :bag, :uuid
    map_belongs_to :fixity_alg, :fixity_algorithm, sub_method: :name
    map_belongs_to :protocol, :protocol, sub_method: :name
    map_belongs_to :from_node, :from_node, model_class: Node, sub_method: :namespace
    map_belongs_to :to_node, :to_node, model_class: Node, sub_method: :namespace
  end
end