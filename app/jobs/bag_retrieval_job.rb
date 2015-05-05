class BagRetrievalJob < ActiveJob::Base
  queue_as :default

  def perform(request, staging_dir)
    destination = File.join staging_dir, request.id.to_s
    FileUtils.mkdir_p(destination) unless File.exists? destination
    perform_rsync(request.source_location, destination)
    request.status = :downloaded
    request.save!
    file_destination = File.join(destination, File.basename(request.source_location))
    BagUnpackJob.perform_later(request, file_destination)
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
