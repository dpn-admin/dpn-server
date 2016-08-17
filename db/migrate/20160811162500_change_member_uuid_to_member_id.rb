class ChangeMemberUuidToMemberId < ActiveRecord::Migration
  def change
    rename_column :members, :uuid, :member_id
  end
end
