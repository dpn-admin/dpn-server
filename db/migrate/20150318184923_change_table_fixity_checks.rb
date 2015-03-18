class ChangeTableFixityChecks < ActiveRecord::Migration
  def change
    change_table :fixity_checks do |t|
      t.remove :node_id
    end
  end
end
