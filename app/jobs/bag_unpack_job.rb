class BagUnpackJob < ActiveJob::Base
  queue_as :default

  def perform(request, bag_location)
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
    BagFixityJob.perform_later(request, bag_location)
    BagValidateJob.perform_later(request, bag_location)
  end


  protected
  def unpack_tar(file)
    serialized_bag = SerializedBag.new(file)
    bag = serialized_bag.unserialize!
    return bag.location
  end
end
