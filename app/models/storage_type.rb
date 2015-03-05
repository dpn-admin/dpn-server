class StorageType < ActiveRecord::Base
  has_many :nodes

  include Lowercased
  make_lowercased :name
end
