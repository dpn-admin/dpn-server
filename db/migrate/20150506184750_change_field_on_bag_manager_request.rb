class ChangeFieldOnBagManagerRequest < ActiveRecord::Migration
  def change
    rename_column :bag_manager_requests, :bag_valid, :validity
  end
end
