class CreateReplicationStatuses < ActiveRecord::Migration
  def change
    create_table :replication_statuses do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :replication_statuses, :name, unique: true
  end
end
