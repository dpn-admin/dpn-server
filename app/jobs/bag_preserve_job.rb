class BagPreserveJob < ActiveJob::Base
  queue_as :internal

  def perform(request, bag_location, storage_dir)
    unless request.cancelled
      bag = Bag.new(bag_location)
      pairtree = Pairtree.at(storage_dir, create: false)
      ppath = pairtree.mk(bag.uuid)
      perform_rsync(File.join(bag_location, "*"), ppath.path)
      request.status = :preserved
      request.preservation_location = ppath.path
      request.save!
    end
  end

  protected
  def perform_rsync(source_location, dest_location)
    options = ["-r -k --partial -q --copy-unsafe-links --preallocate"]
    Rsync.run(source_location, dest_location, options) do |result|
      if result.success? == false
        raise RuntimeError, "Failed to transfer"
      end
    end
  end
end
