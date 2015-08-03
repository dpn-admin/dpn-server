# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class AddNamespaceToFrequentAppleRunTime < ActiveRecord::Migration
  def change
    add_column :frequent_apple_run_times, :namespace, :string, null: false
    remove_index :frequent_apple_run_times, :name
    add_index :frequent_apple_run_times, [:name, :namespace], unique: true
  end
end
