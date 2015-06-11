class BagValidateJob < ActiveJob::Base
  queue_as :default

  def perform(request, bag_location)
    unless request.cancelled
      bag = Bag.new(bag_location)
      request.validity = bag.valid?
      request.save!
    end
  end
end
