# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class DeleteTableFrequentAppleRunTimes < ActiveRecord::Migration
  def change
    drop_table :frequent_apple_run_times
  end
end
