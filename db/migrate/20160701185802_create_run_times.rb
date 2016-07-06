# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class CreateRunTimes < ActiveRecord::Migration
  def change
    create_table :run_times do |t|
      t.string :name, null: false
      t.datetime :last_success, null: false, default: Time.at(0)
    end

    add_index :run_times, :name, unique: true
  end

end
