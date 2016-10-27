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
    ordering = {}
    if orders
      orders.split(',').each do |order_column|
        if [:created_at, :updated_at].include?(order_column.to_sym)
          ordering[order_column.to_sym] = :desc
        end
      end
    end
    return ordering
  end

  def convert_bool(value)
    if value == true || value =~ (/^(true|t|yes|y|1)$/i)
      return true
    elsif value == false || value.blank? || value =~ (/^(false|f|no|n|0)$/i)
      return false
    else
      return value
    end
  end

  private
  def record_not_found
    render nothing: true, status: 404
  end

  def convert_time_strings
    [:updated_at, :created_at].each do |key|
      if params.has_key?(key)
        begin
          params[key] = Time.zone.parse(params[key])
        rescue ArgumentError
          params[key] = nil
        end
      end
    end
  end

end
