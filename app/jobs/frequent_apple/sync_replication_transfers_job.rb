require "frequent_apple"
require "json"

# Job to get the latest version of each non-local replication
# transfer from the from_node, and copy the update to the
# local node.
class FrequentApple::SyncReplicationTransfersJob < ActiveJob::Base
  queue_as :external
  include RunTimeManagement
  include Remote

  def perform(target_namespace, local_node_namespace = Rails.configuration.local_node)
    if target_namespace != local_node_namespace
      repl_url = "/replicate/?from_node=#{target_namespace}&after=#{last_run_time}"
      FrequentApple.get_and_depaginate(remote_client, repl_url) do |transfers|
        update_transfers(local_client, transfers)
      end
    end
  end

  protected
  def update_transfers(client, transfers)
    transfers.each do |transfer|
      resp = client.post("/replicate/", transfer.to_json)
      unless resp.ok?
        client.put("/replicate/#{transfer[:replication_id]}", transfer.to_json)
      end
    end
  end


end

