class ApiV1::BagMgr::RequestsController < ApplicationController
  include Authenticate
  append_before_action :require_is_self

  def index
    @requests = BagManagerRequest.all
    render json: @requests
  end


  def show
    @request = BagManagerRequest.find(params[:id])
    render json: @request
  end


  def create
    params.require(:source_location)
    @request = BagManagerRequest.create(source_location: params[:source_location],
                             status: :requested)
    render json: @request, status: 201
  end


  def downloaded
    params.require(:id)
    @request = BagManagerRequest.find(params[:id])
    @request.update!(status: :downloaded)
    render json: @request, status: 200
  end


  def unpacked
    params.require(:id)
    @request = BagManagerRequest.find(params[:id])
    @request.update!(status: :unpacked)
    render json: @request, status: 200
  end


  def fixity
    params.require(:id)
    params.require(:fixity)
    @request = BagManagerRequest.find(params[:id])
    @request.update!(fixity: params[:fixity])
    render json: @request, status: 200
  end


  def validity
    params.require(:id)
    params.require(:validity)
    @request = BagManagerRequest.find(params[:id])
    @request.update!(validity: params[:validity])
    render json: @request, status: 200
  end


  def preserved
    params.require(:id)
    @request = BagManagerRequest.find(params[:id])
    @request.update!(status: :preserved)
    render json: @request, status: 200
  end


  def cancel
    params.require(:id)
    @request = BagManagerRequest.find(params[:id])
    @request.update!(cancelled: true)
    render json: @request, status: 200
  end


  protected
  def require_is_self
    if @requester.namespace != Rails.configuration.local_namespace
      render json: "Only allowed by local node.", status: 403
      return
    end
  end
end
