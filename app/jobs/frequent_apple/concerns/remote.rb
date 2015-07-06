module FrequentApple; end
module Remote
  extend ActiveSupport::Concern

  included do
    before_perform do |job|
      remote_namespace = job.arguments[0]
      local_namespace = job.arguments[1]
      logger.debug("local=#{local_namespace}, remote=#{remote_namespace}")

      local_node = Node.find_by_namespace!(local_namespace)
      @local_client = FrequentApple.client(local_node.api_root, local_node.auth_credential)
      logger.debug("Created local_client with api_root=#{local_node.api_root} and auth_credential=#{local_node.auth_credential}")

      remote_node = Node.find_by_namespace!(remote_namespace)
      @remote_client = FrequentApple.client(remote_node.api_root, remote_node.auth_credential)
      logger.debug("Created remote_client with api_root=#{remote_node.api_root} and auth_credential=#{remote_node.auth_credential}")
    end
  end

  def local_client
    return @local_client
  end

  def remote_client
    return @remote_client
  end


end

