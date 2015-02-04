class Protocol < ActiveRecord::Base
  has_and_belongs_to_many :nodes, :join_table => "supported_protocols", :uniq => true
end
