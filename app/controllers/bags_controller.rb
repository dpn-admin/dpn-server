# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class BagsController < ApplicationController
  include Authenticate
  include Pagination
  include Adaptation

  local_node_only :create, :update, :destroy
  uses_pagination :index
  adapt!

  def index
    @bags = Bag.updated_after(params[:after])
      .updated_before(params[:before])
      .with_admin_node_id(params[:admin_node_id])
      .with_ingest_node_id(params[:ingest_node_id])
      .with_member_id(params[:member_id])
      .with_bag_type(params[:type])
      .order(parse_ordering(params[:order_by]))
      .page(@page)
      .per(@page_size)

    render "shared/index", status: 200
  end


  def show
    @bag = Bag.find_by_uuid!(params[:uuid])
    render "shared/show", status: 200
  end


  def create
    if Bag.find_by_uuid(params[:uuid]).present?
      render nothing: true, status: 409 and return
    else
      @bag = case params[:type]
      when DataBag.to_s
        DataBag.new
      when RightsBag.to_s
        RightsBag.new
      when InterpretiveBag.to_s
        InterpretiveBag.new
      else
        Bag.new
      end
      if @bag.update_with_associations(create_params(params))
        render "shared/create", status: 201
      else
        render "shared/errors", status: 400
      end
    end
  end


  def update
    @bag = Bag.find_by_uuid!(params[:uuid])

    if @bag.update_with_associations(update_params(params))
      render "shared/update", status: 200
    else
      render "shared/errors", status: 400
    end
  end


  def destroy
    bag = Bag.find_by_uuid!(params[:uuid])
    bag.destroy!
    render nothing: true, status: 204
  end


  private


  def create_params(params)
    new_params = params.permit(Bag.attribute_names)
    new_params.merge! params.slice(
      :replicating_nodes, :version_family,
      :rights_bags, :interpretive_bags)
    return new_params
  end

  def update_params(params)
    create_params(params)
  end


end
