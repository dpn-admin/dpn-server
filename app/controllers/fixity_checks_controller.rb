# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class FixityChecksController < ApplicationController
  include Authenticate
  include Pagination
  include Adaptation

  local_node_only :create
  uses_pagination :index
  adapt!

  def index
    @fixity_checks = FixityCheck.created_after(params[:after])
      .created_before(params[:before])
      .with_node_id(params[:node_id])
      .with_bag_id(params[:bag_id])
      .page(@page)
      .per(@page_size)
    render "shared/index", status: 200
  end


  def create
    if FixityCheck.find_by_fixity_check_id(params[:fixity_check_id]).present?
      render nothing: true, status: 409 and return
    else
      @fixity_check = FixityCheck.new(create_params)
      if @fixity_check.save
        render "shared/create", status: 201
      else
        render "shared/errors", status: 400
      end
    end
  end


  private
  def create_params
    params.permit(FixityCheck.attribute_names)
  end

end