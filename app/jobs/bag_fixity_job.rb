class BagFixityJob < ActiveJob::Base
  queue_as :default

  def perform(request, bag_location)
    bag = Bag.new(bag_location)
    request.fixity = bag.fixity(:sha256)
  end
end
