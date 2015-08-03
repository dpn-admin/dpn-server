# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class CreateFrequentAppleRunTimes < ActiveRecord::Migration
  def change
    create_table :frequent_apple_run_times do |t|
      t.string :name, null: false
      t.datetime :last_run_time, null: false, default: Time.at(0) #unix epoch
    end
    add_index :frequent_apple_run_times, :name, unique: true
  end
end
