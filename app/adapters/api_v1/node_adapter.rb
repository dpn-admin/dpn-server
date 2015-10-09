# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module ApiV1
  class NodeAdapter < ::Adapter

    PUBLIC_HASH_KEYS = [
      :name,
      :namespace,
      :api_root,
      :ssh_pubkey,
      :replicate_from,
      :replicate_to,
      :restore_from,
      :restore_to,
      :protocols,
      :fixity_algorithms,
      :created_at,
      :updated_at,
      :storage
    ]

    def self.from_model(model)
      internals = {
        name: model.name,
        namespace: model.namespace,
        api_root: model.api_root,
        ssh_pubkey: model.ssh_pubkey,
        storage_region_id: model.storage_region_id,
        storage_region_name: model.storage_region.name,
        storage_type_id: model.storage_type_id,
        storage_type_name: model.storage_type.name,
        updated_at: model.updated_at,
        created_at: model.created_at,
        replicate_from_nodes: model.replicate_from_nodes,
        replicate_from_nodes_namespaces: model.replicate_from_nodes.pluck(:namespace),
        replicate_to_nodes: model.replicate_to_nodes,
        replicate_to_nodes_namespaces: model.replicate_to_nodes.pluck(:namespace),
        restore_from_nodes: model.restore_from_nodes,
        restore_from_nodes_namespaces: model.restore_from_nodes.pluck(:namespace),
        restore_to_nodes: model.restore_to_nodes,
        restore_to_nodes_namespaces: model.restore_to_nodes.pluck(:namespace),
        protocols: model.protocols,
        protocols_names: model.protocols.pluck(:name),
        fixity_algs: model.fixity_algs,
        fixity_algs_names: model.fixity_algs.pluck(:name),
        auth_credential: model.auth_credential,
        private_auth_token: model.private_auth_token
      }

      self.new(internals, {})
    end


    def self.from_public(public_hash)
      internals = {
        name: public_hash[:name],
        namespace: public_hash[:namespace],
        api_root: public_hash[:api_root],
        ssh_pubkey: public_hash[:ssh_pubkey],
        replicate_from_nodes: Node.where(namespace: public_hash[:replicate_from]),
        replicate_from_nodes_namespaces: public_hash[:replicate_from],
        replicate_to_nodes: Node.where(namespace: public_hash[:replicate_to]),
        replicate_to_nodes_namespaces: public_hash[:replicate_to],
        restore_from_nodes: Node.where(namespace: public_hash[:restore_from]),
        restore_from_nodes_namespaces: public_hash[:restore_from],
        restore_to_nodes: Node.where(namespace: public_hash[:restore_to]),
        restore_to_nodes_namespaces: public_hash[:restore_to],
        protocols: Protocol.where(name: public_hash[:protocols]),
        protocols_names: public_hash[:protocols],
        fixity_algs: FixityAlg.where(name: public_hash[:fixity_algorithms]),
        fixity_algs_names: public_hash[:fixity_algorithms],
        auth_credential: public_hash[:auth_credential],
        private_auth_token: public_hash[:private_auth_token]
      }

      [:created_at, :updated_at].each do |key|
        if public_hash[key].is_a? String
          internals[key] = time_from_string(public_hash[key])
        end
      end

      if public_hash[:storage].respond_to? :has_key?
        internals[:storage_region_name] = public_hash[:storage][:region]
        storage_region = StorageRegion.find_by_name(public_hash[:storage][:region])
        internals[:storage_region_id] = storage_region ? storage_region.id : nil
        internals[:storage_type_name] = public_hash[:storage][:type]
        storage_type = StorageType.find_by_name(public_hash[:storage][:type])
        internals[:storage_type_id] = storage_type ? storage_type.id : nil
      end

      array_fields = [
        :replicate_from_nodes,
        :replicate_to_nodes,
        :restore_from_nodes,
        :restore_to_nodes,
        :protocols,
        :fixity_algs
      ]

      array_fields.each do |field|
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
        name: @internals[:name],
        namespace: @internals[:namespace],
        api_root: @internals[:api_root],
        ssh_pubkey: @internals[:ssh_pubkey],
        storage_region_id: @internals[:storage_region_id],
        storage_type_id: @internals[:storage_type_id],
        updated_at: @internals[:updated_at],
        created_at: @internals[:created_at],
        replicate_from_nodes: @internals[:replicate_from_nodes],
        replicate_to_nodes: @internals[:replicate_to_nodes],
        restore_from_nodes: @internals[:restore_from_nodes],
        restore_to_nodes: @internals[:restore_to_nodes],
        protocols: @internals[:protocols],
        fixity_algs: @internals[:fixity_algs],
        auth_credential: @internals[:auth_credential],
        private_auth_token: @internals[:private_auth_token]
      }
    end


    def to_public_hash
      @public_hash ||= {
        name: @internals[:name],
        namespace: @internals[:namespace],
        api_root: @internals[:api_root],
        ssh_pubkey: @internals[:ssh_pubkey],
        storage: {
          region: @internals[:storage_region_name],
          type: @internals[:storage_type_name]
        },
        updated_at: @internals[:updated_at].to_formatted_s(:dpn),
        created_at: @internals[:created_at].to_formatted_s(:dpn),
        replicate_from: @internals[:replicate_from_nodes_namespaces],
        replicate_to: @internals[:replicate_to_nodes_namespaces],
        restore_from: @internals[:restore_from_nodes_namespaces],
        restore_to: @internals[:restore_to_nodes_namespaces],
        protocols: @internals[:protocols_names],
        fixity_algorithms: @internals[:fixity_algs_names]
      }
    end


  end
end