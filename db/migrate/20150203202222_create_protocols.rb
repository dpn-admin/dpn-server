class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
