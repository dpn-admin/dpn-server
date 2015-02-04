class Node < ActiveRecord::Base
  has_many :original_bags, :class_name => "Bag", :foreign_key => "original_node_id"
  has_many :admin_bags, :class_name => "Bag", :foreign_key => "admin_node_id"

  belongs_to :storage_region
  belongs_to :storage_type

  has_and_belongs_to_many :fixity_algs, :join_table => "supported_fixity_algs", :uniq => true
  has_and_belongs_to_many :protocols, :join_table => "supported_protocols", :uniq => true
end