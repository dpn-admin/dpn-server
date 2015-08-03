# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class FrequentApple::RunTime < ActiveRecord::Base

  # We set this manually as autoloading for ActiveJobs was not
  # picking up the parent module's prefix.
  def self.table_name
    "frequent_apple_run_times"
  end

  after_initialize :defaults!

  validates :name, presence: true
  validates :namespace, presence: true
  validates :last_run_time, presence: true
  validates_uniqueness_of :name, scope: :namespace

  def defaults!
    self.last_run_time ||= Time.at(0)
  end

end
