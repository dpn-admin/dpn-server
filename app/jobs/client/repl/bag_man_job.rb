# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    # A job class that updates BagManRequest#last_error when
    # a failure is encountered.
    class BagManJob < ActiveJob::Base
      rescue_from StandardError do |exception|
        request = job.arguments.first
        request.last_error = "#{exception.message}\n#{exception.backtrace}"
        request.save
        raise
      end

    end

  end
end
