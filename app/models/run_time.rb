# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class RunTime < ActiveRecord::Base
  after_initialize :defaults!

  validates :name, presence: true, uniqueness: true
  validates :last_success, presence: true

  def defaults!
    self.last_success ||= Time.at(0).utc
  end


end
