# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class NodeAdapter < ::AbstractAdapter

  map_simple :name, :name
  map_simple :namespace, :namespace
  map_simple :api_root, :api_root
  map_simple :ssh_pubkey, :ssh_pubkey

  map_has_many :replicate_from_nodes, :replicate_from, model_class: Node, sub_method: :namespace
  map_has_many :replicate_to_nodes, :replicate_to, model_class: Node, sub_method: :namespace
  map_has_many :restore_from_nodes, :restore_from, model_class: Node, sub_method: :namespace
  map_has_many :restore_to_nodes, :restore_to, model_class: Node, sub_method: :namespace
  map_has_many :protocols, :protocols, sub_method: :name
  map_has_many :fixity_algs, :fixity_algorithms, sub_method: :name

  hidden_field :private_auth_token
  map_from_public :private_auth_token do |token|
    {private_auth_token: token}
  end

  hidden_field :auth_credential
  map_from_public :auth_credential do |cred|
    {auth_credential: cred}
  end

  map_to_public :storage_region_id do |id|
    {storage: {region: StorageRegion.find_by(id: id).name}}
  end
  map_to_public :storage_type_id do |id|
    {storage: {type: StorageType.find_by(id: id).name}}
  end
  map_from_public :storage do |storage|
    result = {
      storage_region_id: nil,
      storage_type_id: nil
    }
    if storage.respond_to? :has_key?
      region = StorageRegion.find_by(name: storage[:region])
      type   = StorageType.find_by(name: storage[:type])
      result[:storage_region_id] = region ? region.id : nil
      result[:storage_type_id] = type ? type.id : nil
    end
    result
  end

end
