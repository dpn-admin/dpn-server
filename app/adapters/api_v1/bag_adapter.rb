# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module ApiV1
  class BagAdapter < ::Adapter

    PUBLIC_HASH_KEYS = [
      :uuid,
      :ingest_node,
      :interpretive,
      :rights,
      :replicating_nodes,
      :admin_node,
      :member,
      :fixities,
      :local_id,
      :size,
      :first_version_uuid,
      :version,
      :bag_type,
      :updated_at,
      :created_at
    ]


    def self.from_model(model)
      internals = {
        uuid: model.uuid,
        ingest_node_id: model.ingest_node.id,
        ingest_node_namespace: model.ingest_node.namespace,
        interpretive: model.interpretive_bags,
        interpretive_uuids: model.interpretive_bags.pluck(:uuid),
        rights: model.rights_bags,
        rights_uuids: model.rights_bags.pluck(:uuid),
        replicating_nodes: model.replicating_nodes,
        replicating_nodes_namespaces: model.replicating_nodes.pluck(:namespace),
        admin_node_id: model.admin_node.id,
        admin_node_namespace: model.admin_node.namespace,
        member_id: model.member.id,
        member_uuid: model.member.uuid,
        local_id: model.local_id,
        size: model.size,
        version_family: model.version_family,
        first_version_uuid: model.version_family.uuid,
        version: model.version,
        model_bag_type: model.type,
        public_bag_type: model.type.to_s[0],
        model_fixities: model.fixity_checks,
        updated_at: model.updated_at,
        created_at: model.created_at
      }

      internals[:public_fixities] = {}
      model.fixity_checks.each do |item|
        internals[:public_fixities][item.fixity_alg.name.to_sym] = item.value
      end

      self.new(internals, {})
    end


    def self.from_public(public_hash)
      internals = {
        uuid: public_hash[:uuid],
        ingest_node_id: Node.where(namespace: public_hash[:ingest_node]).ids[0],
        ingest_node_namespace: public_hash[:ingest_node],
        interpretive: InterpretiveBag.where(uuid: public_hash[:interpretive]),
        interpretive_uuids: public_hash[:interpretive],
        rights: RightsBag.where(uuid: public_hash[:rights]),
        rights_uuids: public_hash[:rights],
        replicating_nodes: Node.where(namespace: public_hash[:replicating_nodes]),
        replicating_nodes_namespaces: public_hash[:replicating_nodes],
        admin_node_id: Node.where(namespace: public_hash[:admin_node]).ids[0],
        admin_node_namespace: public_hash[:admin_node],
        member_id: Member.where(uuid: public_hash[:member]).ids[0],
        member_uuid: public_hash[:member],
        local_id: public_hash[:local_id],
        size: public_hash[:size],
        version_family: VersionFamily.find_or_initialize_by(uuid: public_hash[:first_version_uuid]),
        first_version_uuid: public_hash[:first_version_uuid],
        version: public_hash[:version],
        model_bag_type: model_bag_type(public_hash[:bag_type]),
        public_bag_type: public_hash[:bag_type] ? public_hash[:bag_type].upcase : nil,
        public_fixities: public_hash[:fixities]
      }

      internals[:model_fixities] = []
      if public_hash[:fixities].respond_to? :keys
        public_hash[:fixities].keys.each do |public_fixity_alg|
          internals[:model_fixities] << FixityCheck.find_or_initialize_by(
            fixity_alg: FixityAlg.find_by_name(public_fixity_alg),
            value: public_hash[:fixities][public_fixity_alg])
        end
      end

      [:created_at, :updated_at].each do |key|
        if public_hash[key].is_a? String
          internals[key] = time_from_string(public_hash[key])
        end
      end

      [:interpretive, :rights, :replicating_nodes].each do |field|
        public_field_size = public_hash[field] ? public_hash[field].size : 0
        internals[field].fill(nil, internals[field].size, public_field_size - internals[field].size)
      end

      extras = {}
      (public_hash.keys - PUBLIC_HASH_KEYS).each do |extra_key|
        extras[extra_key] = public_hash[extra_key]
      end

      self.new(internals, extras)
    end


    def to_model_hash
      @model_hash ||= {
        uuid: @internals[:uuid],
        ingest_node_id: @internals[:ingest_node_id],
        interpretive_bags: @internals[:interpretive],
        rights_bags: @internals[:rights],
        replicating_nodes: @internals[:replicating_nodes],
        admin_node_id: @internals[:admin_node_id],
        member_id: @internals[:member_id],
        local_id: @internals[:local_id],
        size: @internals[:size],
        version: @internals[:version],
        version_family: @internals[:version_family],
        type: @internals[:model_bag_type],
        fixity_checks: @internals[:model_fixities],
        updated_at: @internals[:updated_at],
        created_at: @internals[:created_at]
      }
    end


    def to_public_hash
      @public_hash ||= {
        uuid: @internals[:uuid],
        ingest_node: @internals[:ingest_node_namespace],
        interpretive: @internals[:interpretive_uuids],
        rights: @internals[:rights_uuids],
        replicating_nodes: @internals[:replicating_nodes_namespaces],
        admin_node: @internals[:admin_node_namespace],
        member: @internals[:member_uuid],
        fixities: @internals[:public_fixities],
        local_id: @internals[:local_id],
        size: @internals[:size],
        first_version_uuid: @internals[:first_version_uuid],
        version: @internals[:version],
        bag_type: @internals[:public_bag_type],
        created_at: @internals[:created_at].to_formatted_s(:dpn),
        updated_at: @internals[:updated_at].to_formatted_s(:dpn)
      }
    end

    private
    def self.model_bag_type(public_type)
      case public_type
        when "D", "d"
          "DataBag"
        when "R", "r"
          "RightsBag"
        when "I", "i"
          "InterpretiveBag"
        else
          nil
      end
    end

  end
end
