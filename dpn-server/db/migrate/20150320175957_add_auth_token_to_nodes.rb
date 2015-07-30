class AddAuthTokenToNodes < ActiveRecord::Migration
  def change
    change_table :nodes do |t|
      t.string :private_auth_token
      t.index :private_auth_token, unique: true
    end
  end
end
