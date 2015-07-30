class RemoveTimestampsFromReplicatingNodes < ActiveRecord::Migration
  def change
    remove_column :replicating_nodes, :created_at, :string
    remove_column :replicating_nodes, :updated_at, :string
  end
end
