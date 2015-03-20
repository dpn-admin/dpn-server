class AddSaltToNode < ActiveRecord::Migration
  def change
    add_column :nodes, :salt, :string
  end
end
