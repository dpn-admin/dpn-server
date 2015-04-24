module Pagination
  extend ActiveSupport::Concern

  module ClassMethods
    def uses_pagination(fields)
      before_action :check_pagination_params, only: [fields].flatten
    end
  end


  def link_to_next_page(collection_or_count)
    if collection_or_count.respond_to?(:total_count)
      count = collection_or_count.total_count
    else
      count = collection_or_count
    end
    next_page = nil
    if @page * @page_size < count
      next_page = build_url(@page+1, @page_size)
    end

    return next_page
  end


  def link_to_previous_page
    prev_page = nil
    if @page > 1
      prev_page = build_url(@page-1, @page_size)
    end

    return prev_page
  end


  protected
  def check_pagination_params
    begin
      @page = Integer(params[:page])
      @page_size = Integer(params[:page_size])
      return true
    rescue ArgumentError
      render nothing: true, status: 400
    end
  end


  def build_url(page, page_size)
    "#{request.original_url.split('?').first}?page=#{@page}&page_size=#{@page_size}"
  end



end