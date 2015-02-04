class RenameSupportedFixityAlgs < ActiveRecord::Migration
  def change
    rename_table :supported_fixity_algs, :nodes_fixity_algs
  end
end
