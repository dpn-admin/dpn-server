# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class BagManRequest < ActiveRecord::Base

  ### Associations
  belongs_to :replication_transfer, inverse_of: :bag_man_request

  ### Static Validations
  validates :last_step_completed, presence: true
  validates :source_location, presence: true
  validates :cancelled, inclusion: {in: [false, true]}

  ### ActiveRecord::Dirty Validations
  validates :unpacked_location, read_only: true, on: :update,
    unless: proc {|r| r.unpacked_location_changed?(from: nil)}
  validates :preservation_location, read_only: true, on: :update,
    unless: proc {|r| r.preservation_location_changed?(from: nil)}
  validates :fixity, read_only: true, on: :update,
    unless: proc {|r| r.fixity_changed?(from: nil)}


  ### Modifications and Concerns
  enum last_step_completed: {
    created: 0,
    retrieved: 1,
    unpacked: 2,
    validated: 5,
    fixityd: 6,
    stored: 3,
  }


  # Cancel this record, and inform the replication transfer.
  def cancel!(reason)
    unless cancelled
      transaction do
        update!(cancelled: true, cancel_reason: reason)
        replication_transfer.cancel!(reason, last_error)
        send_cancel(replication_transfer)
      end
    end
  end


  # The staging location of the downloaded bag, unpacked bag.
  def staging_location(staging_dir = Rails.configuration.staging_dir)
    destination = File.join staging_dir, self.id.to_s
    extension = File.extname source_location
    return File.join(destination, File.basename(source_location, extension))
  end


  # Begin the series of transactions described by this
  # bag management request.
  def begin!
    ::Client::Repl::BagRetrievalJob.perform_later(self, Rails.configuration.staging_dir.to_s)
  end


  # Notify this request that the bag has been retrieved.
  def set_retrieved!
    update!(last_step_completed: :retrieved)
    ::Client::Repl::BagUnpackJob.perform_later(self, staging_location)
  end


  # Notify this request that the bag has been unpacked.
  def set_unpacked!(unpacked_location)
    update!(unpacked_location: unpacked_location, last_step_completed: :unpacked)
    ::Client::Repl::BagValidateJob.perform_later(self, unpacked_location)
  end


  # Notify this request that the bag has been validated
  def set_validated!(validity)
    update!(last_step_completed: :validated)
    if validity
      ::Client::Repl::BagFixityJob.perform_later(self, unpacked_location)
    else
      cancel!('bag_invalid')
    end
  end


  # Notify this request that a fixity value has been generated.
  def set_fixityd!(fixity_value)
    transaction do
      update!(fixity: fixity_value, last_step_completed: :fixityd)
      replication_transfer.update!(fixity_value: fixity)
      send_update(replication_transfer)
    end
  end


  # Notify this request that the bag has been stored.
  def set_stored!(preservation_location)
    transaction do
      update!(preservation_location: preservation_location, last_step_completed: :stored)
      replication_transfer.update!(stored: true)
      send_update(replication_transfer)
    end
  end


  # Notify this request that it should store the bag permanently.
  def okay_to_preserve!
    ::Client::Repl::BagPreserveJob.perform_later(self, unpacked_location, Rails.configuration.repo_dir)
  end


  private

  def send_update(transfer)
    Client::Repl::PostJob.perform_later(
      transfer,
      transfer.from_node.namespace,
      "update_replication",
      ReplicationTransferAdapter.to_s
    )
  end


  def send_cancel(transfer)
    Client::Repl::CancelJob.perform_later(
      transfer,
      transfer.from_node.namespace,
      "replicate",
      "update_replication",
      ReplicationTransferAdapter.to_s
    )
  end


end
