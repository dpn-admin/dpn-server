class BagFixityJob < ActiveJob::Base
  queue_as :default

  def perform(request, bag_location)
    unless request.cancelled
      bag = Bag.new(bag_location)
      request.fixity = bag.fixity(:sha256)
    end
  end
end
