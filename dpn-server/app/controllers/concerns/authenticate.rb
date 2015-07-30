module Authenticate
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
  end

  module ClassMethods
    def local_node_only(*args)
      append_before_action :require_is_self, only: [args].flatten
    end
  end

  protected
  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      @requester = Node.find_by_private_auth_token(token)
      return @requester != nil
    end
  end

  def require_is_self
    if @requester.nil? || @requester.namespace != Rails.configuration.local_namespace
      render json: "Only allowed by local node.", status: 403 and return
    end
  end

end