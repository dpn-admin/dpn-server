# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class IngestsController < ApplicationController
  include Authenticate
  include Pagination
  include Adaptation
  
  local_node_only :create
  uses_pagination :index
  adapt!
  
  def index
    @ingests = Ingest.created_after(params[:after])
      .created_before(params[:before])
      .with_bag(params[:bag])
      .with_ingested(params[:ingested])
      .latest_only(convert_bool(params[:latest]))
      .page(@page)
      .per(@page_size)
    render "shared/index", status: 200
  end
  
  
  def create
    if Ingest.find_by_ingest_id(params[:ingest_id]).present?
      render nothing: true, status: 409 and return
    else
      @ingest = Ingest.new(create_params(params))
      if @ingest.save
        render "shared/create", status: 201
      else
        render "shared/errors", status: 400
      end
    end
  end
  
  
  private
  SCALAR_PARAMS = [:ingest_id, :ingested, :created_at]
  ASSOCIATED_PARAMS = [:bag, :nodes]

  def create_params(params)
    params
      .permit(SCALAR_PARAMS)
      .merge(params.slice(*ASSOCIATED_PARAMS))
  end

end