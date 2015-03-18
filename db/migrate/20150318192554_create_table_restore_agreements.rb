class CreateTableRestoreAgreements < ActiveRecord::Migration
  def change
    create_table :restore_agreements do |t|
      t.integer :from_node_id, null: false
      t.integer :to_node_id, null: false
      t.timestamps null: false
    end
  end
end
