class CreateRestoreStatuses < ActiveRecord::Migration
  def change
    create_table :restore_statuses do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :restore_statuses, :name, unique: true
  end
end
