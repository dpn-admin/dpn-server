# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe 'OkComputerStatus' do
  describe 'GET /status' do
    it 'returns application version' do
      get '/status/all.json'
      status_response = JSON.parse(response.body)
      expect(status_response.keys).to include 'app_version'
      message = status_response['app_version']['message']
      expect(message).to include DPN::Server::Application::VERSION
    end
  end
end
