# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require_relative '../../../app/presenters/api_v1/node_presenter'

class ApiV1::NodesController < ApplicationController
  include Authenticate
  include Pagination

  local_node_only :create, :update, :update_auth_credential, :destroy
  uses_pagination :index

  before_action :accept_newer_only, only: :update


  def index
    raw_nodes = Node.page(@page).per(@page_size)
    @nodes = raw_nodes.collect do |node|
      ApiV1::NodePresenter.new(node)
    end

    output = {
      :count => raw_nodes.total_count,
      :next => link_to_next_page(raw_nodes.total_count),
      :previous => link_to_previous_page,
      :results => @nodes
    }

    render json: output
  end

  def show
    node = Node.find_by_namespace!(params[:namespace])
    @node = ApiV1::NodePresenter.new(node)
    render json: @node
  end

  # This method is internal
  def create
    expected_params = [:name, :namespace, :api_root, :ssh_pubkey,
      :replicate_from, :replicate_to, :restore_from, :restore_to,
      :protocols, :fixity_algorithms, :storage,
      :created_at, :updated_at, :private_auth_token
    ]

    unless expected_params.all? {|param| params.has_key?(param)}
      render nothing: true, status: 400
      return
    end

    unless params[:storage].respond_to?(:has_key?) && params[:storage].has_key?(:region) && params[:storage].has_key?(:type)
      render nothing: true, status: 400
      return
    end

    node = Node.new

    node.name = params[:name]
    node.namespace = params[:namespace]
    node.api_root = params[:api_root]
    node.ssh_pubkey = params[:ssh_pubkey]
    node.replicate_to_nodes = Node.where(:namespace => params[:replicate_to])
    node.replicate_from_nodes = Node.where(:namespace => params[:replicate_from])
    node.restore_to_nodes = Node.where(:namespace => params[:restore_to])
    node.restore_from_nodes = Node.where(:namespace => params[:restore_from])
    node.protocols = Protocol.where(:name => params[:protocols])
    node.fixity_algs = FixityAlg.where(:name => params[:fixity_algorithms])
    node.storage_region = StorageRegion.find_by_name(params[:storage][:region])
    node.storage_type = StorageType.find_by_name(params[:storage][:type])
    node.private_auth_token = params[:private_auth_token]
    node.created_at = params[:created_at]

    if node.save
      render nothing: true, content_type: "application/json", status: 201, location: api_v1_node_url(node)
    else
      if node.errors[:namespace].include?("has already been taken")
        render nothing: true, status: 409
      else
        render nothing: true, status: 400
      end
    end
  end


  # This method is internal
  def update
    expected_params = [:name, :namespace, :api_root, :ssh_pubkey,
      :replicate_from, :replicate_to, :restore_from, :restore_to,
      :protocols, :fixity_algorithms, :storage,
      :created_at, :updated_at
    ]

    unless expected_params.all? {|param| params.has_key?(param)}
      render nothing: true, status: 400 and return
    end

    unless params[:storage].respond_to?(:has_key?) && params[:storage].has_key?(:region) && params[:storage].has_key?(:type)
      render nothing: true, status: 400 and return
    end

    node = Node.find_by_namespace!(params[:namespace])

    node.name = params[:name]
    node.api_root = params[:api_root]
    node.ssh_pubkey = params[:ssh_pubkey]
    node.replicate_to_nodes = Node.where(:namespace => params[:replicate_to])
    node.replicate_from_nodes = Node.where(:namespace => params[:replicate_from])
    node.restore_to_nodes = Node.where(:namespace => params[:restore_to])
    node.restore_from_nodes = Node.where(:namespace => params[:restore_from])
    node.protocols = Protocol.where(:name => params[:protocols])
    node.fixity_algs = FixityAlg.where(:name => params[:fixity_algorithms])
    node.storage_region = StorageRegion.find_by_name(params[:storage][:region])
    node.storage_type = StorageType.find_by_name(params[:storage][:type])

    if node.save
      render json: ApiV1::NodePresenter.new(node), status: 200
    else
      render nothing: true, status: 400
    end
  end


  # This method is internal
  # Update the auth_credential issued to use by the target node
  def update_auth_credential
    node = Node.find_by_namespace!(params.require(:namespace))
    node.auth_credential = params.require(:auth_credential)
    render nothing: true, status: 200
  end


  # This method is internal
  # This method is for testing purposes only.
  def destroy
    if Rails.env.production?
      render nothing: true, status: 403 and return
    end

    node = Node.find_by_namespace!(params[:namespace])
    node.destroy!
    render nothing: true, status: 204
  end

  protected
  def accept_newer_only
    node = Node.find_by_namespace!(params[:namespace])

    if params[:updated_at] < node.updated_at
      render json: "Body describes an old record.", status: 400 and return
    end
  end


end
