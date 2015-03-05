class ReplicationStatus < ActiveRecord::Base
  has_many :replication_transfers

  include Lowercased
  make_lowercased :name
end
