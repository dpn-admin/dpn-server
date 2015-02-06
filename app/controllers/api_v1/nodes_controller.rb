require_relative '../../../app/presenters/api_v1/node_presenter'

class ApiV1::NodesController < ApplicationController

  def index
    nodes = Node.all.collect do |node|
      ApiV1::NodePresenter.new(node)
    end

    output = {
      :count => nodes.size,
      :results => nodes
    }

    render json: output
  end

  def show
    node = Node.find_by_namespace!(params[:namespace])
    render json: ApiV1::NodePresenter.new(node)
  end

  # This method is internal
  def create
    node = Node.new
    node.namespace = params[:node][:namespace]
    node.name = params[:node][:name]
    node.ssh_pubkey = params[:node][:ssh_pubkey]
    node.storage_region = StorageRegion.find_by_name(params[:node][:storage][:region])
    node.storage_type = StorageType.find_by_name(params[:node][:storage][:region])
    node.fixity_algs = FixityAlg.where(:name => params[:node][:fixity_algs])
    node.protocols = Protocol.where(:name => params[:node][:protocols])
    node.to_nodes = Node.where(:namespace => params[:node][:replicate_to])
    node.from_nodes = Node.where(:namespace => params[:node][:replicate_from])
    node.save
    render json: ApiV1::NodePresenter.new(node)
  end

  # This method is internal
  def update
    node = Node.find_by_namespace!(params[:namespace])
    node.name = params[:node][:name]
    node.ssh_pubkey = params[:node][:ssh_pubkey]
    node.storage_region = StorageRegion.find_by_name(params[:node][:storage][:region])
    node.storage_type = StorageType.find_by_name(params[:node][:storage][:region])
    node.fixity_algs = FixityAlg.where(:name => params[:node][:fixity_algs])
    node.protocols = Protocol.where(:name => params[:node][:protocols])
    node.to_nodes = Node.where(:namespace => params[:node][:replicate_to])
    node.from_nodes = Node.where(:namespace => params[:node][:replicate_from])
    node.save
    render json: ApiV1::NodePresenter.new(node)
  end

end
