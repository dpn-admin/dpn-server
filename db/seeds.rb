# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require "securerandom"
require "json"

if Rails.env.production?
  hash = JSON.parse(File.read("db/seeds/prod.seeds.json"), symbolize_names: true)
else
  hash = JSON.parse(File.read("db/seeds/dev.seeds.json"), symbolize_names: true)
end

hash[:replication_status].each do |status|
  ReplicationStatus.create!(name: status)
end

hash[:fixity_alg].each do |alg|
  FixityAlg.create!(name: alg)
end

hash[:protocol].each do |protocol|
  Protocol.create!(name: protocol)
end

hash[:storage_region].each do |region|
  StorageRegion.create!(name: region)
end

hash[:storage_type].each do |type|
  StorageType.create!(name: type)
end

if hash.has_key?(:node)
  nodes = []
  hash[:node].each_value do |node_entry|
    new_node = Node.create!(
        namespace: node_entry[:namespace],
        name: node_entry[:namespace],
        storage_region: StorageRegion.find_by_name(node_entry[:storage_region]),
        storage_type: StorageType.find_by_name(node_entry[:storage_type]),
        fixity_algs: FixityAlg.where(name: node_entry[:fixity_algs]),
        protocols: Protocol.where(name: node_entry[:protocols]),
        api_root: node_entry[:api_root],
        private_auth_token: node_entry[:private_auth_token],
        auth_credential: node_entry[:auth_credential])
    nodes << new_node
  end

  nodes.each do |from_node|
    nodes.each do |to_node|
      if from_node != to_node
        from_node.replicate_to_nodes << to_node
        from_node.restore_to_nodes << to_node
      end
      from_node.save!
    end
  end
end

# Require any other seeds we might have.
Dir["db/seeds/**/seeds.rb"].each do |f|
  load f
end