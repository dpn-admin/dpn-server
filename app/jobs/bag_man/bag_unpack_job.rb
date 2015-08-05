# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module BagMan

  class BagUnpackJob < ActiveJob::Base
    queue_as :internal

    def perform(request, bag_location)
      unless request.cancelled
        if File.directory?(bag_location) == false
          case File.extname bag_location
            when ".tar"
              bag_location = unpack_tar(bag_location)
            else
              raise RuntimeError, "could not identify file type"
          end
        end
        request.status = :unpacked
        request.save!
        BagValidateJob.perform_later(request, bag_location)
      end
    end


    protected
    def unpack_tar(file)
      serialized_bag = DPN::Bagit::SerializedBag.new(file)
      bag = serialized_bag.unserialize!
      return bag.location
    end
  end

end