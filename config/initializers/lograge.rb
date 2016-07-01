# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


DPN::Server::Application.configure do
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    exceptions = %w(controller action format id)
    { params: event.payload[:params].except(*exceptions) }
  end
end