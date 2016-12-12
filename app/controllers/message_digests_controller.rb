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
      .with_bag(params[:bag])
      .order(parse_ordering(params[:order_by]))
      .page(@page)
      .per(@page_size)
    
    render "shared/index", status: 200
  end
  
  
  def show
    @message_digest = MessageDigest.find_by!(
      bag_id: params[:bag]&.id,
      fixity_alg_id: params[:fixity_alg]&.id)
    render "shared/show", status: 200
  end
  
  def create
    existing = MessageDigest.find_by(
      bag_id: params[:bag]&.id,
      fixity_alg_id: params[:fixity_alg]&.id
    )
    if existing
      render nothing: true, status: 409 and return
    else
      @message_digest = MessageDigest.new(create_params(params))
      if @message_digest.save
        render "shared/create", status: 201
      else
        render "shared/errors", status: 400
      end
    end
  end
  
  private

  SCALAR_PARAMS = [:value, :created_at]
  ASSOCIATED_PARAMS = [:bag, :node, :fixity_alg]

  def create_params(params)
    params
      .permit(SCALAR_PARAMS)
      .merge(params.slice(*ASSOCIATED_PARAMS))
  end
  
end