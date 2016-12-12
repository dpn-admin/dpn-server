# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    # BagRetrievalJob uses rsync to retrieve a DPN bag from a remote node
    class BagRetrievalJob < BagManJob
      queue_as :repl

      def perform(request, staging_dir)
        return if request.cancelled
        destination = File.join staging_dir, request.id.to_s
        FileUtils.mkdir_p(destination) unless File.exist? destination
        perform_rsync(request.source_location, destination)
        request.set_retrieved!
      end

      protected

      SSH_OPTIONS = [
        "-o BatchMode=yes",
        "-o ConnectTimeout=3",
        "-o ChallengeResponseAuthentication=no",
        "-o PasswordAuthentication=no",
        "-o UserKnownHostsFile=/dev/null",
        "-o StrictHostKeyChecking=no",
        "-i #{Rails.configuration.transfer_private_key}"
      ]

      def rsync_options
        @rsync_options ||= ["-a --partial -q -k --copy-unsafe-links -e 'ssh #{SSH_OPTIONS.join(" ")}' "]
      end

      def perform_rsync(source_location, dest_location)
        Rsync.run(source_location, dest_location, rsync_options) do |result|
          raise "Failed to transfer" unless result.success?
        end
      end
    end
  end
end
