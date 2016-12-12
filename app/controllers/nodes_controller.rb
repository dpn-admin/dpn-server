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
      @node = Node.new
      if @node.update_with_associations(create_params(params))
        render "shared/create", status: 201
      else
        render "shared/errors", status: 400
      end
    end
  end


  def update
    @node = Node.find_by_namespace!(params[:namespace])
    if @node.update_with_associations(update_params(params))
      render "shared/update", status: 200
    else
      render "shared/errors", status: 400
    end
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
  def create_params(params)
    new_params = params.permit(Node.attribute_names)
    new_params.merge! params.slice(
      :replicate_from_nodes, :replicate_to_nodes,
      :restore_from_nodes, :restore_to_nodes,
      :protocols, :fixity_algs
    )
    return new_params
  end
  
  def update_params(params)
    create_params(params).except(:auth_credential, :private_auth_token)
  end



end
