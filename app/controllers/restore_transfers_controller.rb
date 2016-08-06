# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class RestoreTransfersController < ApplicationController
  include Authenticate
  include Adaptation
  include Pagination

  local_node_only :create, :destroy
  uses_pagination :index
  adapt!

  def index
    @restore_transfers = RestoreTransfer.updated_after(params[:after])
      .updated_before(params[:before])
      .with_bag_id(params[:bag_id])
      .with_to_node_id(params[:to_node_id])
      .with_from_node_id(params[:from_node_id])
      .with_accepted(params[:accepted])
      .with_finished(params[:finished])
      .with_cancelled(params[:cancelled])
      .with_cancel_reason(params[:cancel_reason])
      .order(parse_ordering(params[:order_by]))
      .page(@page)
      .per(@page_size)

    render "shared/index", status: 200
  end


  def show
    @restore_transfer = RestoreTransfer.find_by_restore_id!(params[:restore_id])
    render "shared/show", status: 200
  end


  def create
    if RestoreTransfer.where(restore_id: params[:restore_id]).exists?
      render nothing: true, status: 409 and return
    else
      @restore_transfer = RestoreTransfer.new(create_params(params))
      if @restore_transfer.save
        render "shared/create", status: 201
      else
        render "shared/errors", status: 400
      end
    end
  end


  def update
    @restore_transfer = RestoreTransfer.find_by_restore_id!(params[:restore_id])

    if @requester != @restore_transfer.from_node && @requester.namespace != Rails.configuration.local_namespace
      render nothing: true, status: 403 and return
    end

    if @restore_transfer.update(update_params(params))
      render "shared/update", status: 200
    else
      render "shared/errors", status: 400
    end

  end


  def destroy
    restore_transfer = RestoreTransfer.find_by_restore_id!(params[:restore_id])
    restore_transfer.destroy!
    render nothing: true, status: 204
  end

  private
  def create_params(params)
    params.permit(RestoreTransfer.attribute_names + [:requester])
  end


  def update_params(params)
    create_params(params)
  end


end
