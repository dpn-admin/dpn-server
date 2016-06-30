# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class InterpretiveBag < Bag
  has_many :data_interpretives, inverse_of: :interpretive_bag
  has_many :data_bags, through: :data_interpretives
end