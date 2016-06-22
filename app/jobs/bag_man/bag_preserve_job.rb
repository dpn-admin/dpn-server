# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'pairtree'

module BagMan
  ##
  # BagPreserveJob transfers a retrieved BagIt bag into the storage location
  class BagPreserveJob < ActiveJob::Base
    queue_as :internal

    def perform(request, bag_location, storage_dir)
      return if request.cancelled
      bag = DPN::Bagit::Bag.new(bag_location)
      pairtree = Pairtree.at(storage_dir, create: false)
      pairtree ||= Pairtree.at(storage_dir, create: true)
      ppath = pairtree.mk(bag.uuid)
      perform_rsync(File.join(bag_location, "*"), ppath.path)
      request.status = :preserved
      request.preservation_location = ppath.path
      request.save!
    end

    protected

    def perform_rsync(source_location, dest_location)
      options = ["-r -k --partial -q --copy-unsafe-links"]
      Rsync.run(source_location, dest_location, options) do |result|
        raise "Failed to transfer" unless result.success?
      end
    end
  end
end
