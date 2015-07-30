class BagValidateJob < ActiveJob::Base
  queue_as :internal

  def perform(request, bag_location)
    unless request.cancelled
      bag = DPN::Bagit::Bag.new(bag_location)
      request.validity = bag.valid?
      request.save!
    end
  end
end
