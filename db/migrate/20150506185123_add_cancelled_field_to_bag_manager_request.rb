class AddCancelledFieldToBagManagerRequest < ActiveRecord::Migration
  def change
    add_column :bag_manager_requests, :cancelled, :boolean, default: false
  end
end
