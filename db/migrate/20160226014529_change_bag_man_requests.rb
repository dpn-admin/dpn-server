class ChangeBagManRequests < ActiveRecord::Migration

  class BagManRequest < ActiveRecord::Base
    enum last_step_completed: {
      created: 0,
      retrieved: 1,
      unpacked: 2,
      validated: 5,
      fixityd: 6,
      stored: 3,
      rejected: 4
    }
  end

  def up
    begin
      ActiveRecord::Base.record_timestamps = false

      add_column :bag_man_requests, :cancel_reason, :text, default: nil
      rename_column :bag_man_requests, :status, :last_step_completed

      BagManRequest.where(validity: true, last_step_completed: :unpack)
        .update_all(last_step_completed: :validate)

      BagManRequest.where.not(fixity: nil).where(last_step_completed: :unpack)
        .update_all(last_step_completed: :fixity)

      BagManRequest.where(validity: false)
        .update_all(cancelled: true, cancel_reason: 'bag_invalid')

      BagManRequest.where(last_step_completed: :rejected)
        .update_all(cancelled: true, cancel_reason: 'reject')

      remove_column :bag_man_requests, :validity
    ensure
      ActiveRecord::Base.record_timestamps = true
    end
  end


  def down
    begin
      ActiveRecord::Base.record_timestamps = false

      add_column :bag_man_requests, :validity, :boolean, null: true

      BagManRequest.where(last_step_completed: :validate)
        .update_all(validity: true, last_step_completed: :unpack)

      BagManRequest.where(last_step_completed: :fixity)
        .update_all(last_step_completed: :unpack)

      BagManRequest.where(cancel_reason: 'bag_invalid')
        .update_all(validity: false)

      BagManRequest.where(cancel_reason: 'reject')
        .update_all(last_step_completed: :rejected)

      rename_column :bag_man_requests, :last_step_completed, :status
      remove_column :bag_man_requests, :cancel_reason
    ensure
      ActiveRecord::Base.record_timestamps = true
    end
  end

end
