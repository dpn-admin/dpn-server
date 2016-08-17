class RefactorReplicationTransfer < ActiveRecord::Migration

  class ReplicationTransfer < ActiveRecord::Base
    enum status: {
      requested: 0,
      rejected: 1,
      received: 2,
      confirmed: 3,
      stored: 4,
      cancelled: 5
    }
  end


  def up
    begin
      ActiveRecord::Base.record_timestamps = false

      add_column :replication_transfers, :store_requested, :boolean, null: false, default: false
      add_column :replication_transfers, :stored, :boolean, null: false, default: false
      add_column :replication_transfers, :cancelled, :boolean, null: false, default: false
      add_column :replication_transfers, :cancel_reason, :text, default: nil

      ReplicationTransfer.where(status: :cancelled)
        .update_all(cancelled: true, cancel_reason: 'other')

      ReplicationTransfer.where(fixity_accept: false)
        .update_all(cancelled: true, cancel_reason: 'fixity_reject')

      ReplicationTransfer.where(bag_valid: false)
        .update_all(cancelled: true, cancel_reason: 'bag_invalid')

      ReplicationTransfer.where(status: :rejected)
        .update_all(cancelled: true, cancel_reason: 'reject')

      ReplicationTransfer.where(status: :stored)
        .update_all(store_requested: true, stored: true)

      ReplicationTransfer.where(status: :confirmed)
        .update_all(store_requested: true)

      remove_column :replication_transfers, :fixity_accept
      remove_column :replication_transfers, :bag_valid
      remove_column :replication_transfers, :status

    ensure
      ActiveRecord::Base.record_timestamps = true
    end


  end

  def down
    begin
      ActiveRecord::Base.record_timestamps = false

      add_column :replication_transfers, :fixity_accept, :boolean
      add_column :replication_transfers, :bag_valid, :boolean
      add_column :replication_transfers, :status, :integer, null: false, default: 0

      ReplicationTransfer.where(cancelled: true)
        .update_all(status: :cancelled)

      ReplicationTransfer.where(cancel_reason: 'fixity_reject')
        .update_all(fixity_accept: false)

      ReplicationTransfer.where(cancel_reason: 'bag_invalid')
        .update_all(bag_valid: false)

      ReplicationTransfer.where(cancel_reason: 'reject')
        .update_all(status: :rejected)

      ReplicationTransfer.where(store_requested: true, cancelled: false, stored: false)
        .update_all(status: :confirmed, fixity_accept: true, bag_valid: true)

      ReplicationTransfer.where(stored: true, cancelled: false)
        .update_all(status: :stored, fixity_accept: true, bag_valid: true)

      ReplicationTransfer.where(fixity_value: nil, cancelled: false)
        .update_all(status: :requested)

      remove_column :replication_transfers, :store_requested
      remove_column :replication_transfers, :stored
      remove_column :replication_transfers, :cancelled
      remove_column :replication_transfers, :cancel_reason

    ensure
      ActiveRecord::Base.record_timestamps = true
    end
  end


end
