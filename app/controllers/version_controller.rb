# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

# Returns DPN::Server::Application::VERSION
class VersionController < ApplicationController
  include Authenticate

  def show
    versions = {
      app_version: DPN::Server::Application::VERSION,
      api_version: VERSION
    }
    render json: versions
  end
end
