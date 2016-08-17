# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class StorageType < ActiveRecord::Base
  include Lowercased
  make_lowercased :name

  def self.find_fields
    Set.new [:name]
  end
  
  has_many :nodes

  validates :name, presence: true
end
