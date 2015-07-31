class ChangeBagsTable < ActiveRecord::Migration
  def change
    rename_column :bags, :original_node_id, :ingest_node_id
  end
end
