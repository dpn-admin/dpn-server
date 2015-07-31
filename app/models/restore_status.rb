class RestoreStatus < ActiveRecord::Base
  has_many :restore_transfers

  include Lowercased
  make_lowercased :name
end
