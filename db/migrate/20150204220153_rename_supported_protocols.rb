class RenameSupportedProtocols < ActiveRecord::Migration
  def change
    rename_table :supported_protocols, :nodes_protocols
  end
end
