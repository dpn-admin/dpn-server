class AddLastErrorToBagManRequests < ActiveRecord::Migration
  def change
    add_column :bag_man_requests, :last_error, :text
  end
end
