class BagMan::BagFixityJob < ActiveJob::Base
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
