class CreateIngests < ActiveRecord::Migration
  def change
    create_table :ingests do |t|
      t.string :ingest_id, null: false
      t.integer :bag_id, null: false
      t.boolean :ingested, null: false
      t.datetime :created_at, null: false
    end

    add_index :ingests, :ingest_id, unique: true

    add_foreign_key :ingests, :bags,
      column: :bag_id,
      on_delete: :nullify,
      on_update: :cascade

    create_table :nodes_ingests do |t|
      t.integer :node_id, null: false
      t.integer :ingest_id, null: false
    end

    add_index :nodes_ingests, [:node_id, :ingest_id], unique: true

    add_foreign_key :nodes_ingests, :nodes,
      column: :node_id,
      on_delete: :cascade,
      on_update: :cascade

    add_foreign_key :nodes_ingests, :ingests,
      column: :ingest_id,
      on_delete: :cascade,
      on_update: :cascade

  end
end
