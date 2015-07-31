class CreateSupportedFixityAlgs < ActiveRecord::Migration
  def change
    create_table :supported_fixity_algs do |t|
      t.references :node, null: false
      t.references :fixity_alg, null: false
    end
    add_index :supported_fixity_algs, [:node_id, :fixity_alg_id], unique: true
  end
end
