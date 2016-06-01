# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class FixityAlg < ActiveRecord::Base
  include Lowercased
  make_lowercased :name
  
  has_many :supported_fixity_algs, inverse_of: :fixity_alg
  has_many :nodes, through: :supported_fixity_algs
  
  has_many :fixity_checks
  has_many :replication_transfers
end
