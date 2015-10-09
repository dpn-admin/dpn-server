# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module ApiV1
  class ReplicationTransferAdapter < ::Adapter

    PUBLIC_HASH_KEYS = [
      :replication_id,
      :from_node,
      :to_node,
      :uuid,
      :fixity_algorithm,
      :fixity_nonce,
      :fixity_value,
      :fixity_accept,
      :bag_valid,
      :status,
      :protocol,
      :link,
      :created_at,
      :updated_at
    ]


    def self.from_model(model)
      internals = {
        replication_id: model.replication_id,
        from_node_id: model.from_node.id,
        from_node_namespace: model.from_node.namespace,
        to_node_id: model.to_node.id,
        to_node_namespace: model.to_node.namespace,
        bag_id: model.bag.id,
        bag_uuid: model.bag.uuid,
        status: model.status,
        protocol_id: model.protocol.id,
        protocol_name: model.protocol.name,
        link: model.link,
        fixity_alg_id: model.fixity_alg.id,
        fixity_alg_name: model.fixity_alg.name,
        fixity_nonce: model.fixity_nonce,
        fixity_value: model.fixity_value,
        fixity_accept: model.fixity_accept,
        bag_valid: model.bag_valid,
        created_at: model.created_at,
        updated_at: model.updated_at
      }
      self.new(internals, {})
    end


    def self.from_public(public_hash)
      internals = {
        replication_id: public_hash[:replication_id],
        from_node_namespace: public_hash[:from_node],
        to_node_namespace: public_hash[:to_node],
        bag_uuid: public_hash[:uuid],
        status: public_hash[:status],
        protocol_name: public_hash[:protocol],
        link: public_hash[:link],
        fixity_alg_name: public_hash[:fixity_algorithm],
        fixity_nonce: public_hash[:fixity_nonce],
        fixity_value: public_hash[:fixity_value],
        fixity_accept: public_hash[:fixity_accept],
        bag_valid: public_hash[:bag_valid]
      }

      [:created_at, :updated_at].each do |key|
        if public_hash[key].is_a? String
          timestamp = public_hash[key].gsub(/\.[0-9]*Z\Z/, "Z")
          internals[key] = time_from_string(timestamp)
        end
      end

      from_node = Node.find_by_namespace(public_hash[:from_node])
      internals[:from_node_id] = from_node ? from_node.id : nil
      to_node = Node.find_by_namespace(public_hash[:to_node])
      internals[:to_node_id] = to_node ? to_node.id : nil
      bag = Bag.find_by_uuid(public_hash[:uuid])
      internals[:bag_id] = bag ? bag.id : nil
      protocol = Protocol.find_by_name(public_hash[:protocol])
      internals[:protocol_id] = protocol ? protocol.id : nil
      fixity_alg = FixityAlg.find_by_name(public_hash[:fixity_algorithm])
      internals[:fixity_alg_id] = fixity_alg ? fixity_alg.id : nil


      extras = {}
      (public_hash.keys - PUBLIC_HASH_KEYS).each do |extra_key|
        extras[extra_key] = public_hash[extra_key]
      end

      self.new(internals, extras)
    end


    def to_model_hash
      @model_hash ||= {
        replication_id: @internals[:replication_id],
        from_node_id: @internals[:from_node_id],
        to_node_id: @internals[:to_node_id],
        bag_id: @internals[:bag_id],
        status: @internals[:status],
        protocol_id: @internals[:protocol_id],
        link: @internals[:link],
        fixity_alg_id: @internals[:fixity_alg_id],
        fixity_nonce: @internals[:fixity_nonce],
        fixity_value: @internals[:fixity_value],
        fixity_accept: @internals[:fixity_accept],
        bag_valid: @internals[:bag_valid],
        created_at: @internals[:created_at],
        updated_at: @internals[:updated_at]
      }

      return @model_hash
    end


    def to_public_hash
      @public_hash ||= {
        replication_id: @internals[:replication_id],
        from_node: @internals[:from_node_namespace],
        to_node: @internals[:to_node_namespace],
        uuid: @internals[:bag_uuid],
        status: @internals[:status],
        protocol: @internals[:protocol_name],
        link: @internals[:link],
        fixity_algorithm: @internals[:fixity_alg_name],
        fixity_nonce: @internals[:fixity_nonce],
        fixity_value: @internals[:fixity_value],
        fixity_accept: @internals[:fixity_accept],
        bag_valid: @internals[:bag_valid],
        created_at: @internals[:created_at].to_formatted_s(:dpn),
        updated_at: @internals[:updated_at].to_formatted_s(:dpn)
      }
    end

  end
end