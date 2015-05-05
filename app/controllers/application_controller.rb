class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private
  def record_not_found
    render nothing: true, status: 404
  end
end
