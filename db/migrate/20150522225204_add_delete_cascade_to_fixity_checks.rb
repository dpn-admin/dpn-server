class AddDeleteCascadeToFixityChecks < ActiveRecord::Migration
  def change
    remove_foreign_key :fixity_checks, :bags
    add_foreign_key :fixity_checks, :bags, on_update: :cascade, on_delete: :cascade
  end
end
