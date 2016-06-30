# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class DataInterpretive < ActiveRecord::Base
  self.table_name = "data_interpretive"
  
  belongs_to :data_bag,         inverse_of: :data_interpretives, touch: true
  belongs_to :interpretive_bag, inverse_of: :data_interpretives, touch: true
  
  validates_uniqueness_of :data_bag_id, scope: :interpretive_bag_id
end
