# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class FixityCheck < ActiveRecord::Base
  belongs_to :fixity_alg
  belongs_to :bag

  validates :value, presence: true
end