# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class BagManRequest < ActiveRecord::Base
  enum status: {
           requested: 0,
           downloaded: 1,
           unpacked: 2,
           preserved: 3,
           rejected: 4
       }

  has_one :replication_transfer, inverse_of: :bag_man_request

  validates :source_location, presence: true
  validates :validity, inclusion: {in: [nil, false, true]}
  validates :cancelled, inclusion: {in: [false, true]}

  after_create do |record|
    ::BagMan::BagRetrievalJob.perform_later(record, Rails.configuration.staging_dir.to_s)
  end

  after_update :update_replication_transfer,
     if: :should_update_replication_transfer?

  def staging_location(staging_dir = Rails.configuration.staging_dir)
    destination = File.join staging_dir, self.id.to_s
    return File.join(destination, File.basename(self.source_location))
  end

  private

  def update_replication_transfer
    if replication_transfer
      replication_transfer.bag_valid = validity
      replication_transfer.fixity_value = fixity
      new_status = nil
      if cancelled
        new_status = :cancelled
      else
        case status.to_sym
          when :preserved
            new_status = :stored
          when :rejected
            new_status = :rejected
          when :unpacked
            if fixity && validity
              new_status = :received
            else
              new_status = :cancelled
            end
        end
      end
      if new_status
        replication_transfer.status = new_status
        replication_transfer.requester = Node.local_node!
      end
      replication_transfer.save!
    end
  end

  def should_update_replication_transfer?
    status_changed? || validity_changed? || fixity_changed? || cancelled_changed?
  end
end
