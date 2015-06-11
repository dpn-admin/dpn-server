require "frequent_apple"
require "json"

# Job to get the latest version of each non-local bag
# from the admin node, and copy the update to the
# local node.
class FrequentApple::SyncBagsJob < ActiveJob::Base
  queue_as :external
  include RunTimeManagement
  include Remote

  def perform(target_namespace, local_node_namespace = Rails.configuration.local_namespace)
    if target_namespace != local_node_namespace
      %w(I R D).each do |bag_type|
        bag_url = "/bag?admin_node=#{target_namespace}&after=#{last_run_time()}&bag_type=#{bag_type}"
        FrequentApple.get_and_depaginate(remote_client, bag_url) do |bags|
          update_bags(local_client, bags)
        end
      end
    end
  end

  protected
  def update_bags(client, bags)
    bags.each do |bag|
      resp =  client.post("/bag", bag.to_json)
      unless resp.ok?
        client.put("/bag/#{bag[:uuid]}", bag.to_json)
      end
    end
  end

end

