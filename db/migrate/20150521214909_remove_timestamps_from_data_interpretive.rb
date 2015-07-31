class RemoveTimestampsFromDataInterpretive < ActiveRecord::Migration
  def change
    remove_column :data_interpretive, :created_at, :string
    remove_column :data_interpretive, :updated_at, :string
  end
end
