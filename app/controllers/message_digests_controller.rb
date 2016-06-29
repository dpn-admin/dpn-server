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
    @message_digest = find_message_digest
    raise ActiveRecord::RecordNotFound unless @message_digest
    render "shared/show", status: 200
  end
  
  def create
    if find_message_digest
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
  
  def find_message_digest
    return MessageDigest
      .where(bag_id: params[:bag_id])
      .where(fixity_alg_id: params[:fixity_alg_id])
      .first
  end

  def create_params
    params.permit(MessageDigest.attribute_names)
  end
  
end