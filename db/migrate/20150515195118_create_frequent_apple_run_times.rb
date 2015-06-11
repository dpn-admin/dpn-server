class CreateFrequentAppleRunTimes < ActiveRecord::Migration
  def change
    create_table :frequent_apple_run_times do |t|
      t.string :name, null: false
      t.datetime :last_run_time, null: false, default: Time.at(0) #unix epoch
    end
    add_index :frequent_apple_run_times, :name, unique: true
  end
end
