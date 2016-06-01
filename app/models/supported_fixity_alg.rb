# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class SupportedFixityAlg < ActiveRecord::Base
  belongs_to :fixity_alg, inverse_of: :supported_fixity_algs, touch: true
  belongs_to :node,       inverse_of: :supported_fixity_algs, touch: true
  validates_uniqueness_of :node_id, scope: :fixity_alg_id
end
