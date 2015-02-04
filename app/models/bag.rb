class Bag < ActiveRecord::Base
  belongs_to :original_node, :foreign_key => "original_node_id"
  belongs_to :admin_node, :foreign_key => "admin_node_id"

  has_many :versions, :class_name => "Bag", :foreign_key => "first_version_bag_id"
  belongs_to :first_version, :class_name => "Bag"
end