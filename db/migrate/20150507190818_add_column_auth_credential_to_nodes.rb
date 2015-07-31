class AddColumnAuthCredentialToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :auth_credential, :string, null: true, default: nil
  end
end
