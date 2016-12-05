# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class VersionFamily < ActiveRecord::Base
  include Lowercased
  make_lowercased :uuid

  def self.find_fields
    Set.new [:uuid]
  end
  
  has_many :bags, :inverse_of => :version_family

  validates :uuid, presence: true,
    format: { with: /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i,
      message: "must be a valid v4 uuid." }

end