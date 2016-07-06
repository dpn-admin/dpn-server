# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module BagMan
  ##
  # BagRetrievalJob uses rsync to retrieve a DPN bag from a remote node
  class BagRetrievalJob < ActiveJob::Base
    queue_as :repl

    def perform(request, staging_dir)
      return if request.cancelled
      destination = File.join staging_dir, request.id.to_s
      FileUtils.mkdir_p(destination) unless File.exist? destination
      perform_rsync(request.source_location, destination)
      request.status = :downloaded
      request.save!
      saved_location = File.join destination, File.basename(request.source_location)
      BagUnpackJob.perform_later(request, saved_location)
    end

    protected

    def perform_rsync(source_location, dest_location)
      options = ["-a --partial -q -k --copy-unsafe-links -e 'ssh -o PasswordAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{Rails.configuration.transfer_private_key}' "]
      Rsync.run(source_location, dest_location, options) do |result|
        raise "Failed to transfer" unless result.success?
      end
    end
  end
end
