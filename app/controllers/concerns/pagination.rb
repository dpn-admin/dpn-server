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
    page_action, @page = check_page_param
    page_size_action, @page_size = check_page_size_param

    if page_action == :error || page_size_action == :error
      render nothing: true, status: 400
    end

    if page_action == :redirect || page_size_action == :redirect
      redirect_to build_url(@page, @page_size)
    end

    return true
  end


  def check_page_param
    if params[:page]
      begin
        page = Integer(params[:page])
        if page < 1
          return :error, nil
        end
      rescue TypeError
        return :error, nil
      end
    else
      return :redirect, 1
    end
    return :success, page
  end


  def check_page_size_param
    if params[:page_size]
      begin
        page_size = Integer(params[:page_size])
        if page_size < 1
          return :error, nil
        elsif page_size > Rails.configuration.max_per_page
          return :redirect, Rails.configuration.max_per_page
        end
      rescue TypeError
        return :error, nil
      end
    else
      return :redirect, Rails.configuration.default_per_page
    end
    return :success, page_size
  end


  def build_url(page, page_size)
    url_for params.merge({page: page, page_size: page_size})
  end



end