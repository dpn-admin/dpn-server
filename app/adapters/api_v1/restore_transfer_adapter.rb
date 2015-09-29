# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module ApiV1
  class RestoreTransferAdapter

    PUBLIC_HASH_KEYS = [
      :restore_id,
      :from_node,
      :to_node,
      :uuid,
      :protocol,
      :status,
      :link,
      :updated_at,
      :created_at
    ]

    def initialize(internals, extras)
      @internals = internals
      @extras = extras
      @model_hash = nil
      @public_hash = nil
      @params_hash = nil
    end


    def self.from_model(model)
      internals = {
        restore_id: model.restore_id,
        from_node_id: model.from_node.id,
        from_node_namespace: model.from_node.namespace,
        to_node_id: model.to_node.id,
        to_node_namespace: model.to_node.namespace,
        bag_id: model.bag.id,
        bag_uuid: model.bag.uuid,
        protocol_id: model.protocol.id,
        protocol_name: model.protocol.name,
        status: model.status,
        link: model.link,
        created_at: model.created_at,
        updated_at: model.updated_at
      }
      self.new(internals, {})
    end


    def self.from_public(public_hash)
      internals = {
        restore_id: public_hash[:restore_id],
        from_node_namespace: public_hash[:from_node],
        to_node_namespace: public_hash[:to_node],
        bag_uuid: public_hash[:uuid],
        protocol_name: public_hash[:protocol],
        status: public_hash[:status],
        link: public_hash[:link]
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

      extras = {}
      (public_hash.keys - PUBLIC_HASH_KEYS).each do |extra_key|
        extras[extra_key] = public_hash[extra_key]
      end

      self.new(internals, extras)
    end


    def to_model_hash
      @model_hash ||= {
        restore_id: @internals[:restore_id],
        from_node_id: @internals[:from_node_id],
        to_node_id: @internals[:to_node_id],
        bag_id: @internals[:bag_id],
        protocol_id: @internals[:protocol_id],
        status: @internals[:status],
        link: @internals[:link],
        created_at: @internals[:created_at],
        updated_at: @internals[:updated_at]
      }
    end


    def to_public_hash
      @public_hash ||= {
        restore_id: @internals[:restore_id],
        from_node: @internals[:from_node_namespace],
        to_node: @internals[:to_node_namespace],
        uuid: @internals[:bag_uuid],
        protocol: @internals[:protocol_name],
        status: @internals[:status],
        link: @internals[:link],
        created_at: @internals[:created_at].to_formatted_s(:dpn),
        updated_at: @internals[:updated_at].to_formatted_s(:dpn)
      }
    end

    def to_params_hash
      @params_hash ||= to_model_hash.merge(@extras) {|key,lhs,rhs| lhs}
    end


    def to_json(options = {})
      return self.to_public_hash.to_json(options)
    end

  end
end
