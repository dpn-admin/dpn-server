class ReplicationStatus < ActiveRecord::Base
  has_many :replication_transfers
end
