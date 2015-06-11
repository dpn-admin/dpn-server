class RemoveTimestampsFromDataRights < ActiveRecord::Migration
  def change
    remove_column :data_rights, :created_at, :string
    remove_column :data_rights, :updated_at, :string
  end
end
