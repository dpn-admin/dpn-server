# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ReplicationTransfersController < ApplicationController
  include Authenticate
  include Adaptation
  include Pagination

  local_node_only :create, :destroy
  uses_pagination :index
  adapt!

  def index
    @replication_transfers = ReplicationTransfer.updated_after(params[:after])
      .with_bag_id(params[:bag_id])
      .with_status(params[:status])
      .with_fixity_accept(params[:fixity_accept])
      .with_bag_valid(params[:bag_valid])
      .with_to_node_id(params[:to_node_id])
      .with_from_node_id(params[:from_node_id])
      .order(parse_ordering(params[:order_by]))
      .page(@page)
      .per(@page_size)

    render "shared/index", status: 200
  end



  def show
    @replication_transfer = ReplicationTransfer.find_by_replication_id!(params[:replication_id])
    render "shared/show", status: 200
  end


  def create
    if ReplicationTransfer.where(replication_id: params[:replication_id]).exists?
      render nothing: true, status: 409 and return
    else
      @replication_transfer = ReplicationTransfer.new(create_params)
      if @replication_transfer.save
        render "shared/create", status: 201
      else
        render "shared/errors", status: 400
      end
    end
  end


  def update
    @replication_transfer = ReplicationTransfer.find_by_replication_id!(params[:replication_id])

    if @requester != @replication_transfer.to_node && @requester.namespace != Rails.configuration.local_namespace
      render nothing: true, status: 403 and return
    end

    @replication_transfer.attributes = update_params
    @replication_transfer.requester = @requester
    unless @replication_transfer.save
      render "shared/errors", status: 400 and return
    end

    render "shared/update", status: 200
  end



  def destroy
    repl = ReplicationTransfer.find_by_replication_id!(params[:replication_id])
    repl.destroy!
    render nothing: true, status: 204
  end


  private
  def create_params
    params.permit(ReplicationTransfer.attribute_names)
  end

  def update_params
    params.permit(
      :bag_id, :from_node_id, :to_node_id,
      :protocol_id, :link, :bag_valid,
      :fixity_alg_id, :fixity_nonce,
      :fixity_value, :fixity_accept, 
      :replication_id, :status, :requester  # note :requester is virtual
    )
  end



end
