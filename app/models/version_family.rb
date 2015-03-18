class VersionFamily < ActiveRecord::Base
  has_many :bags, :inverse_of => :version_family

  include UUIDFormat
  make_uuid :uuid

end