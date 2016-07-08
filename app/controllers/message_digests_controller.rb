# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class MessageDigestsController < ApplicationController
  include Authenticate
  include Pagination
  include Adaptation
  
  local_node_only :create
  uses_pagination :index
  adapt!
  
  def index
    @message_digests = MessageDigest.created_after(params[:after])
      .created_before(params[:before])
      .with_bag_id(params[:bag_id])
      .order(parse_ordering(params[:order_by]))
      .page(@page)
      .per(@page_size)
    
    render "shared/index", status: 200
  end
  
  
  def show
    @message_digest = MessageDigest.find_by!(
      bag_id: params[:bag_id],
      fixity_alg_id: params[:fixity_alg_id])
    render "shared/show", status: 200
  end
  
  def create
    existing = MessageDigest.find_by(
      bag_id: params[:bag_id],
      fixity_alg_id: params[:fixity_alg_id]
    )
    if existing
      render nothing: true, status: 409 and return
    else
      @message_digest = MessageDigest.new(create_params)
      if @message_digest.save
        render "shared/create", status: 201
      else
        render "shared/errors", status: 400
      end
    end
  end
  
  private


  def create_params
    params.permit(MessageDigest.attribute_names)
  end
  
end