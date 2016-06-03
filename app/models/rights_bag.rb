# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class RightsBag < Bag
  has_many :data_rights, class_name: "DataRights", inverse_of: :rights_bag
  has_many :data_bags, through: :data_rights
end