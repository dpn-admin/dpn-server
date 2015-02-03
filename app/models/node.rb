class Node < ActiveRecord::Base
  has_many :send_agreement,
           :foreign_key => "from_id",
           :class_name => "ReplicationAgreement"
  has_many :to_nodes, :through => :send_agreement

  has_many :receive_agreement,
           :foreign_key => "to_id",
           :class_name => "ReplicationAgreement"
  has_many :from_nodes, :through => :receive_agreement

end
