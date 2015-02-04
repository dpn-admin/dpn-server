class Node < ActiveRecord::Base
  has_many :original_bags, :class_name => "Bag", :foreign_key => "original_node_id"
  has_many :admin_bags, :class_name => "Bag", :foreign_key => "admin_node_id"
end