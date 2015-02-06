class ChangeSize < ActiveRecord::Migration
  def change
    change_column :bags, :size, :integer, :limit => 8
  end
end
