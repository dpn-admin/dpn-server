# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


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
      @requester != nil
    end
  end

  def require_is_self
    unless @requester&.local_node?
      render json: "Only allowed by local node.", status: 403 and return
    end
  end

end