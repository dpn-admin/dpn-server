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

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def parse_ordering(orders)
    ordering = {updated_at: :desc}
    if orders
      new_ordering = {}
      orders.split(',').each do |order_column|
        if [:created_at, :updated_at].include?(order_column.to_sym)
          new_ordering[order_column.to_sym] = :desc
        end
      end
      ordering = new_ordering unless new_ordering.empty?
    end
    return ordering
  end

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

end
