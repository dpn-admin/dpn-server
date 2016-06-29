# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module ApiV2
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
        .with_bag_id(params[:bag_id])
        .page(@page)
        .per(@page_size)
      render "shared/index", status: 200
    end
    
    
    def create
      if Ingest.find_by_ingest_id(params[:ingest_id]).present?
        render nothing: true, status: 409 and return
      else
        @ingest = Ingest.new(create_params)
        if @ingest.save
          render "shared/create", status: 201
        else
          render "shared/errors", status: 400
        end
      end
    end
    
    
    private
    def create_params
      params.permit(Ingest.attribute_names)
    end

  end
end