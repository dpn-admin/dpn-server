class CreateReplicationAgreements < ActiveRecord::Migration
  def change
    create_table :replication_agreements do |t|
      t.integer :from_id, null: false
      t.integer :to_id, null: false

      t.timestamps null: false
    end
  end
end
