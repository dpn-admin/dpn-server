# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class Protocol < ActiveRecord::Base
  has_and_belongs_to_many :nodes, :join_table => "supported_protocols", :uniq => true
  has_many :replication_transfers
  has_many :restore_transfers

  include Lowercased
  make_lowercased :name
end
