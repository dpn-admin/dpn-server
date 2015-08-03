# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ReplicationStatus < ActiveRecord::Base
  has_many :replication_transfers

  include Lowercased
  make_lowercased :name
end
