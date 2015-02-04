class CreateSupportedProtocols < ActiveRecord::Migration
  def change
    create_table :supported_protocols do |t|
      t.references :node, null: false
      t.references :protocol, null: false
    end
    add_index :supported_protocols, [:node_id, :protocol_id], unique: true
  end
end
