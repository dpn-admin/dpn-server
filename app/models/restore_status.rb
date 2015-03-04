class RestoreStatus < ActiveRecord::Base
  has_many :restore_transfers

  validates :name, format: { with: /[a-z0-9\-\_\+]+/, message: "lowercase only"}

  before_validation do
    self.name.downcase!
  end
end
