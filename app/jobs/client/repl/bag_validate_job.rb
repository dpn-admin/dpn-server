# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl
    # BagValidateJob checks the validity for a DPN::BagIt::Bag
    # and it updates the request validity field.
    class BagValidateJob < BagManJob
      queue_as :repl

      def perform(request, bag_location)
        return if request.cancelled
        bag = DPN::Bagit::Bag.new(bag_location)
        request.set_validated!(bag.valid?)
      end

    end
  end
end