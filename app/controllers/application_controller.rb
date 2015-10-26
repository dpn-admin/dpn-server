# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :convert_time_strings
  before_action :set_default_response_json

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private
  def record_not_found
    render nothing: true, status: 404
  end

  def convert_time_strings
    [:updated_at, :created_at].each do |key|
      if params.has_key?(key)
        begin
          timestamp = params[key].gsub(/\.[0-9]*Z\Z/, "Z")
          params[key] = time_from_string(timestamp)
        rescue ArgumentError
          params[key] = nil
        end
      end
    end
  end

  def set_default_response_json
    request.format = :json unless params[:format]
  end

end
