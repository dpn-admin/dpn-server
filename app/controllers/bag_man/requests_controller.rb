module BagMan
  class RequestsController < ApplicationController
    include Authenticate
    local_node_only :index, :show, :create, :downloaded, :unpacked, :fixity, :validity, :preserved, :cancel

    def index
      @requests = Request.all
      render json: @requests
    end


    def show
      @request = Request.find(params[:id])
      render json: @request
    end


    def create
      params.require(:source_location)
      request = Request.create!(
          source_location: params[:source_location],
          status: :requested)

      BagRetrievalJob.perform_later(request, Rails.configuration.staging_dir)

      render nothing: true, content_type: "application/json", status: 201,
          location: api_v1_bag_man_requests_url(request)
    end


    def downloaded
      params.require(:id)
      @request = Request.find(params[:id])
      @request.update!(status: :downloaded)
      render json: @request, status: 200
    end


    def unpacked
      params.require(:id)
      @request = Request.find(params[:id])
      @request.update!(status: :unpacked)
      render json: @request, status: 200
    end


    def fixity
      params.require(:id)
      params.require(:fixity)
      @request = Request.find(params[:id])
      @request.update!(fixity: params[:fixity])
      render json: @request, status: 200
    end


    def validity
      params.require(:id)
      params.require(:validity)
      @request = Request.find(params[:id])
      @request.update!(validity: params[:validity])
      render json: @request, status: 200
    end


    def preserved
      params.require(:id)
      @request = Request.find(params[:id])
      @request.update!(status: :preserved)
      render json: @request, status: 200
    end


    def cancel
      params.require(:id)
      @request = Request.find(params[:id])
      @request.update!(cancelled: true)
      render json: @request, status: 200
    end


    def destroy
      params.require(:id)
      Request.destroy(params[:id])
      render nothing: true, status: 204
    end

  end
end