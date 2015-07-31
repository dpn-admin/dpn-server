class VersionFamily < ActiveRecord::Base
  has_many :bags, :inverse_of => :version_family

  include Lowercased
  make_lowercased :uuid

end