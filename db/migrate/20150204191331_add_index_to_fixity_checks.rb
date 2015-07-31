class AddIndexToFixityChecks < ActiveRecord::Migration
  def change
    add_index :fixity_checks, [:bag_id, :fixity_alg_id], unique: true
  end
end
