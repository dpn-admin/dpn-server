module FrequentApple; end
module Remote
  extend ActiveSupport::Concern

  included do
    before_perform do |job|
      remote_namespace = job.arguments[0]
      local_namespace = job.arguments[1]

      local_node = Node.find_by_namespace!(local_namespace)
      @local_client = FrequentApple.client(local_node.api_root, local_node.auth_credential)

      remote_node = Node.find_by_namespace!(remote_namespace)
      @remote_client = FrequentApple.client(remote_node.api_root, remote_node.auth_credential)
    end
  end

  def local_client
    return @local_client
  end

  def remote_client
    return @remote_client
  end


end

