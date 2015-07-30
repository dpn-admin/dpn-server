class AddNamespaceToFrequentAppleRunTime < ActiveRecord::Migration
  def change
    add_column :frequent_apple_run_times, :namespace, :string, null: false
    remove_index :frequent_apple_run_times, :name
    add_index :frequent_apple_run_times, [:name, :namespace], unique: true
  end
end
