# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    # BagFixityJob calculates BagIt fixity using the SHA256 algorithm
    # and updates a request.fixity field.
    class BagFixityJob < BagManJob
      queue_as :repl

      def perform(request, bag_location)
        return if request.cancelled
        bag = DPN::Bagit::Bag.new(bag_location)
        request.set_fixityd!(bag.fixity(:sha256))
      end

    end
  end
end
