# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class NodesController < ApplicationController
  include Authenticate
  include Pagination
  include Adaptation

  local_node_only :create, :update, :update_auth_credential, :destroy
  uses_pagination :index
  adapt!

  def index
    @nodes = Node.all.page(@page).per(@page_size)
    render "shared/index", status: 200
  end


  def show
    @node = Node.find_by_namespace!(params[:namespace])
    render "shared/show", status: 200
  end


  def create
    if Node.find_by_namespace(params[:namespace]).present?
      render nothing: true, status: 409 and return
    else
      @node = Node.new(create_params)
      @node.replicate_from_nodes = params[:replicate_from_nodes]
      @node.replicate_to_nodes = params[:replicate_to_nodes]
      @node.restore_from_nodes = params[:restore_from_nodes]
      @node.restore_to_nodes = params[:restore_to_nodes]
      @node.protocols = params[:protocols]
      @node.fixity_algs = params[:fixity_algs]
      if @node.save
        render "shared/create", status: 201
      else
        render "shared/errors", status: 400
      end
    end
  end


  def update
    @node = Node.find_by_namespace!(params[:namespace])

    update_node(@node)
    unless @node.save
      render "shared/errors", status: 400 and return
    end

    render "shared/update", status: 200
  end


  # Update the auth_credential issued to use by the target node
  # This method is experimental and is not part of the spec.
  def update_auth_credential
    @node = Node.find_by_namespace!(params.require(:namespace))
    @node.auth_credential = params.require(:auth_credential)
    render "shared/update", status: 200
  end


  # This method is for testing purposes only.
  def destroy
    node = Node.find_by_namespace!(params[:namespace])
    node.destroy!
    render nothing: true, status: 204
  end


  private
  def create_params
    params.permit(Node.attribute_names)
  end

  def update_params
    params.permit(:name, :namespace, :ssh_pubkey,
      :api_root,
      :storage_region_id, :storage_type_id)
  end

  def update_node(node)
    node.attributes = update_params
    node.replicate_from_nodes = params[:replicate_from_nodes]
    node.replicate_to_nodes = params[:replicate_to_nodes]
    node.restore_from_nodes = params[:restore_from_nodes]
    node.restore_to_nodes = params[:restore_to_nodes]
    node.protocols = params[:protocols]
    node.fixity_algs = params[:fixity_algs]
    if params[:private_auth_token]
      node.private_auth_token = params[:private_auth_token]
    end
    if params[:auth_credential]
      node.auth_credential = params[:auth_credential]
    end
    return node
  end



end
