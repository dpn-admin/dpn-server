module Authenticate
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
  end

  protected
  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      @requester = Node.find_by_private_auth_token(token)
      return @requester != nil
    end
  end

end