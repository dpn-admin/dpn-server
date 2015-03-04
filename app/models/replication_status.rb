class ReplicationStatus < ActiveRecord::Base
  has_many :replication_transfers

  validates :name, format: { with: /[a-z0-9\-\_\+]+/, message: "lowercase only"}

  before_validation do
    self.name.downcase!
  end
end
