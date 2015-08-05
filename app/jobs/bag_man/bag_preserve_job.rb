# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module BagMan

  class BagPreserveJob < ActiveJob::Base
    queue_as :internal

    def perform(request, bag_location, storage_dir)
      unless request.cancelled
        bag = DPN::Bagit::Bag.new(bag_location)
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

end