require "frequent_apple"
require "json"

# Job to get the latest version of each non-local bag
# from the admin node, and copy the update to the
# local node.
class FrequentApple::SyncBagsJob < ActiveJob::Base
  queue_as :default

  def perform(local_node_namespace = Rails.configuration.local_node)
    current_run_time = Time.now.utc
    last_run_object = FrequentApple::RunTime.find_by_name!(self.class)
    last_run_time = last_run_object.last_run_time.strftime(Time::DATE_FORMATS[:dpn])

    local_node = Node.find_by_namespace!(local_node_namespace)
    client = FrequentApple.client(local_node.api_root, local_node.auth_credential)
    nodes = FrequentApple.get_nodes(client)

    nodes.each do |node|
      if node[:namespace] != local_node_namespace
        auth_cred = Node.find_by_namespace!(node[:namespace]).auth_credential
        client_for_their_node = FrequentApple.client(node[:api_root], auth_cred)
        %w(I R D).each do |bag_type|
          bag_url = "/bag?admin_node=#{node[:namespace]}&after=#{last_run_time}&bag_type=#{bag_type}"
          FrequentApple.get_and_depaginate(client_for_their_node, bag_url) do |bags|
            update_bags(client, bags)
          end
        end
      end
    end

    last_run_object.last_run_time = current_run_time
    last_run_object.save!
  end

  protected
  def update_bags(client, bags)
    bags.each do |bag|
      begin
        unless client.post("/bag", bag.to_json).ok?
          client.put("/bag/#{bag[:uuid]}", bag.to_json)
        end
      rescue HTTPClient::TimeoutError, SocketError, Errno::ECONNREFUSED
        next
      end
    end
  end

end

