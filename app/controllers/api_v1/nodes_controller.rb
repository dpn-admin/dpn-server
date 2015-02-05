require_relative '../../../app/presenters/api_v1/node_presenter'

class ApiV1::NodesController < ApplicationController

  def index
    @nodes = Node.all.collect do |node|
      ApiV1::NodePresenter.new(node)
    end

    output = {
      :count => @nodes.size,
      :results => @nodes
    }

    render json: output

  end

  def show
    @node = Node.find_by_namespace!(params[:namespace])
    render json: ApiV1::NodePresenter.new(@node)
  end

end
