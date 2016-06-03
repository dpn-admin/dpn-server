# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class DataRights < ActiveRecord::Base
  self.table_name = "data_rights"

  belongs_to :data_bag,   inverse_of: :data_rights, touch: true
  belongs_to :rights_bag, inverse_of: :data_rights, touch: true

  validates_uniqueness_of :data_bag_id, scope: :rights_bag_id
end
