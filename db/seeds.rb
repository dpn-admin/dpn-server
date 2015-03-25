# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

[:requested, :rejected, :received, :confirmed, :stored, :cancelled].each do |status|
  ReplicationStatus.create(:name => status)
end

[:requested, :accepted, :rejected, :prepared, :finished, :cancelled].each do |status|
  RestoreStatus.create(:name => status)
end

sha256 = FixityAlg.create(:name => :sha256)
md5 = FixityAlg.create(:name => :md5)

rsync = Protocol.create(:name => :rsync)

default_storage_region = StorageRegion.create(:name => :default)
default_storage_type = StorageType.create(:name => :default)

node_objects = []
nodes = [:sdr, :tdr, :hathi, :aptrust, :chron]
nodes.each do |namespace|
  node_objects << Node.create(:namespace => namespace, :name => namespace) do |node|
    node.storage_region = default_storage_region
    node.storage_type = default_storage_type
    node.fixity_algs << md5
    node.fixity_algs << sha256
    node.protocols << rsync
  end
end

node_objects.each do |from_node|
  node_objects.each do |to_node|
    if from_node != to_node
      from_node.replicate_to_nodes << to_node
      from_node.restore_to_nodes << to_node
    end
  end
end

