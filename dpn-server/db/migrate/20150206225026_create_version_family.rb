class CreateVersionFamily < ActiveRecord::Migration
  def change
    create_table :version_families do |t|
      t.string :uuid, null: false
    end
    add_index :version_families, [:uuid], unique: true

  end
end
