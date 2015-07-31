class ChangeTableBagManagerRequestsToBagManRequests < ActiveRecord::Migration
  def change
    rename_table :bag_manager_requests, :bag_man_requests
  end
end
