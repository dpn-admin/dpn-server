# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.



class ApiV1::RestoreTransfersController < ApplicationController
  include Authenticate
  include Adaptation
  include Pagination

  local_node_only :create, :destroy
  uses_pagination :index


  def index
    ordering = {updated_at: :desc}
    if params[:order_by]
      new_ordering = {}
      params[:order_by].split(',').each do |order_column|
        if [:created_at, :updated_at].include?(order_column.to_sym)
          new_ordering[order_column.to_sym] = :desc
        end
      end
      ordering = new_ordering unless new_ordering.empty?
    end
    @restore_transfers = RestoreTransfer.updated_after(params[:after])
      .with_bag(params[:uuid])
      .with_status(params[:status])
      .with_to_node(params[:to_node])
      .with_from_node(params[:from_node])
      .order(ordering)
      .page(@page)
      .per(@page_size)

    render "shared/index", status: 200
  end


  def show
    @restore_transfer = RestoreTransfer.find_by_restore_id!(params[:restore_id])
    render "shared/show", status: 200
  end


  def create
    if params[:restore_id] && RestoreTransfer.where(restore_id: params[:restore_id]).exists?
      render nothing: true, status: 409 and return
    else
      @restore_transfer = RestoreTransfer.create(create_params)
      if @restore_transfer.save
        render "shared/create", status: 201
      else
        render "shared/errors", status: 400
      end
    end
  end


  def update
    @restore_transfer = RestoreTransfer.find_by_restore_id!(params[:restore_id])

    if @requester != @restore_transfer.to_node && @requester.namespace != Rails.configuration.local_namespace
      render nothing: true, status: 403 and return
    end

    @restore_transfer.from_node_id = params[:from_node_id]
    @restore_transfer.to_node_id = params[:to_node_id]
    @restore_transfer.bag_id = params[:bag_id]
    @restore_transfer.protocol_id = params[:protocol_id]
    @restore_transfer.status = params[:status]
    @restore_transfer.requester = @requester

    unless @restore_transfer.valid?
      render "shared/errors", status: 400 and return
    end


    if params[:updated_at] < @restore_transfer.updated_at
      @restore_transfer.reload
    else
      @restore_transfer.save
    end

    render "shared/update", status: 200
  end


  def destroy
    restore_transfer = RestoreTransfer.find_by_restore_id!(params[:restore_id])
    restore_transfer.destroy!
    render nothing: true, status: 204
  end

  private
  def create_params
    params.permit(RestoreTransfer.attribute_names)
  end

  def update_params
    params.permit(RestoreTransfer.attribute_names).permit(:requester)
  end

end
