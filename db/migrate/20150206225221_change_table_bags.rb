class ChangeTableBags < ActiveRecord::Migration
  def change
    rename_column :bags, :first_version_bag_id, :version_family_id
  end
end
