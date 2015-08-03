# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class DataBag < Bag
  has_and_belongs_to_many :interpretive_bags, :uniq => true, :join_table => "data_interpretive"
  has_and_belongs_to_many :rights_bags, :uniq => true, :join_table => "data_rights"
end