# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module BagMan
  # BagUnpackJob unpacks a DPN::BagIt::SerializedBag (.tar file);
  # on success, it updates the request status to :unpacked and
  # initiates bag validation and fixity calculation.
  class BagUnpackJob < BagManJob
    queue_as :repl

    def perform(request, bag_location)
      return if request.cancelled
      bag_location = unpack_bag(bag_location)
      request.set_unpacked!(bag_location)
    end

    protected

    # @param path [String] bag location
    # @return path [String] unpacked bag location
    def unpack_bag(path)
      return path if File.directory?(path)
      case File.extname path
      when ".tar"
        unpack_tar(path)
      else
        raise "Could not unpack file type"
      end
    end

    # @param file [String] location of a serialized bag (.tar file)
    # @return path [String] location of unpacked bag
    def unpack_tar(file)
      serialized_bag = DPN::Bagit::SerializedBag.new(file)
      bag = serialized_bag.unserialize!
      bag.location
    end
  end
end
