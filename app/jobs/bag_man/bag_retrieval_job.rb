# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module BagMan

  class BagRetrievalJob < ActiveJob::Base
    queue_as :internal

    def perform(request, staging_dir)
      unless request.cancelled
        destination = File.join staging_dir, request.id.to_s
        FileUtils.mkdir_p(destination) unless File.exists? destination
        perform_rsync(request.source_location, destination)
        request.status = :downloaded
        request.save!
        BagUnpackJob.perform_later(request, request.staging_location(staging_dir))
      end
    end

    protected
    def perform_rsync(source_location, dest_location)
      options = ["-a --partial -q -k --copy-unsafe-links -e 'ssh -o PasswordAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{Rails.configuration.transfer_private_key}' "]
      Rsync.run(source_location, dest_location, options) do |result|
        if result.success? == false
          raise RuntimeError, "Failed to transfer"
        end
      end
    end
  end

end
