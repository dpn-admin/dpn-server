# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module BagMan

  class BagFixityJob < ActiveJob::Base
    queue_as :internal

    def perform(request, bag_location)
      unless request.cancelled
        bag = DPN::Bagit::SerializedBag.new(bag_location)
        request.fixity = bag.fixity(:sha256)
        request.save!
        BagUnpackJob.perform_later(request, bag_location)
      end
    end
  end

end