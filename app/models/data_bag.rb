# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class DataBag < Bag
  has_many :data_interpretives, inverse_of: :data_bag
  has_many :interpretive_bags, through: :data_interpretives

  has_many :data_rights, inverse_of: :data_bag, class_name: "DataRights"
  has_many :rights_bags, through: :data_rights
end  
