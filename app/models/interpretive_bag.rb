# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class InterpretiveBag < Bag
  has_and_belongs_to_many :data_bags, :uniq => true, :join_table => "data_interpretive"
end