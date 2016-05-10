class CreateTableFixityChecks < ActiveRecord::Migration
  def change
    create_table :fixity_checks do |t|
      t.string :fixity_check_id, null: false
      t.integer :bag_id, null: false
      t.integer :node_id, null: false
      t.boolean :success, null: false
      t.datetime :fixity_at, null: false
      t.datetime :created_at, null: false
    end
    
    add_index :fixity_checks, :fixity_check_id, unique: true

    add_foreign_key :fixity_checks, :bags,
      column: :bag_id,
      on_delete: :cascade,
      on_update: :cascade
    
    add_foreign_key :fixity_checks, :nodes,
      column: :node_id,
      on_delete: :nullify,
      on_update: :cascade
  end
end
