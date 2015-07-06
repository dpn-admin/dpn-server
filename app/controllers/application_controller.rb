class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :convert_time_strings

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
          params[key] = DateTime.strptime(timestamp, Time::DATE_FORMATS[:dpn])
        rescue ArgumentError
          render json: "Bad #{key}", status: 400 and return
        end
      end
    end
  end

end
