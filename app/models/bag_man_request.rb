# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class BagManRequest < ActiveRecord::Base

  ### Modifications and Concerns
  enum status: {
           requested: 0,
           downloaded: 1,
           unpacked: 2,
           preserved: 3,
           rejected: 4
       }


  def staging_location(staging_dir = Rails.configuration.staging_dir)
    destination = File.join staging_dir, self.id.to_s
    return File.join(destination, File.basename(self.source_location))
  end


  def okay_to_preserve!
    ::BagMan::BagPreserveJob.perform_later(self, staging_location, Rails.configuration.repo_dir)
  end


  def replication_transfer_changed(old_status)
    if old_status != replication_transfer.status
      if old_status.to_sym == :received && replication_transfer.confirmed? && replication_transfer.fixity_accept
        ::BagMan::BagPreserveJob.perform_later(self, staging_location, Rails.configuration.repo_dir)
      elsif [:stored, :rejected, :cancelled].include?(replication_transfer.status.to_sym)
        self.cancelled = true
        self.save!
      end
    end
  end


  ### Associations
  belongs_to :replication_transfer, inverse_of: :bag_man_request


  ### Static Validations
  validates :source_location, presence: true
  validates :validity, inclusion: {in: [nil, false, true]}
  validates :cancelled, inclusion: {in: [false, true]}


  ### Callbacks
  after_create do |record|
    ::BagMan::BagRetrievalJob.perform_later(record, Rails.configuration.staging_dir.to_s)
  end


  after_update if: "status_changed?" do |record|
    case status.to_sym
      when :downloaded
        record.replication_transfer.status = :received
        record.replication_transfer.save!
      when :unpacked
      when :preserved
        record.replication_transfer.status = :stored
        record.replication_transfer.save!
      when :rejected
        record.replication_transfer.status = :rejected
        record.replication_transfer.save!
    end
  end


  after_update if: "validity_changed?" do |record|
    record.replication_transfer.bag_valid = validity
    record.replication_transfer.save!
  end


  after_update if: "fixity_changed?" do |record|
    record.replication_transfer.fixity_value = fixity
    record.replication_transfer.save!
  end


  after_update if: "cancelled_changed?" do |record|
    if cancelled_was != cancelled
      unless [:stored, :rejected, :cancelled].include?(record.replication_transfer.status.to_sym)
        record.replication_transfer.status = :cancelled
        record.replication_transfer.save!
      end
    end
  end


end
