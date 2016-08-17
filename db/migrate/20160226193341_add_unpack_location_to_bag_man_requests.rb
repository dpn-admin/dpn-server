class AddUnpackLocationToBagManRequests < ActiveRecord::Migration
  def change
    add_column :bag_man_requests, :unpacked_location, :string
  end
end
