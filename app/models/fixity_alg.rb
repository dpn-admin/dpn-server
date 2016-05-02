# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class FixityAlg < ActiveRecord::Base
  include Lowercased
  make_lowercased :name

  has_and_belongs_to_many :nodes, :join_table => "supported_fixity_algs", :uniq => true
  has_many :message_digests
  has_many :replication_transfers
end
