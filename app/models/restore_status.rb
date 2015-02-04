class RestoreStatus < ActiveRecord::Base
  has_many :restore_transfers
end
