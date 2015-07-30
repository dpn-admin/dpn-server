class CreateFixityChecks < ActiveRecord::Migration
  def change
    create_table :fixity_checks do |t|
      t.references :node, null: false
      t.references :bag, null: false
      t.references :fixity_alg, null: false
      t.text :value, null: false
      t.timestamp null: false
    end
  end
end
