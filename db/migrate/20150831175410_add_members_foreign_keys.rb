class AddMembersForeignKeys < ActiveRecord::Migration
  def change

      add_column :bags, :member_id, :integer
      
      add_foreign_key :bags, :members,
          column: :member_id,
          on_delete: :restrict,
          on_update: :cascade
  end
end
