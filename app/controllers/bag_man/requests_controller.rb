# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module BagMan
  class BagManRequestsController < ApplicationController
    include Authenticate
    local_node_only :index, :show, :create, :downloaded, :unpacked, :fixity, :validity, :preserved, :cancel

    def index
      @BagManRequests = BagManRequest.all
      render json: @BagManRequests
    end


    def show
      @BagManRequest = BagManRequest.find(params[:id])
      render json: @BagManRequest
    end


    def downloaded
      params.require(:id)
      @BagManRequest = BagManRequest.find(params[:id])
      @BagManRequest.update!(status: :downloaded)
      render json: @BagManRequest, status: 200
    end


    def unpacked
      params.require(:id)
      @BagManRequest = BagManRequest.find(params[:id])
      @BagManRequest.update!(status: :unpacked)
      render json: @BagManRequest, status: 200
    end


    def fixity
      params.require(:id)
      params.require(:fixity)
      @BagManRequest = BagManRequest.find(params[:id])
      @BagManRequest.update!(fixity: params[:fixity])
      render json: @BagManRequest, status: 200
    end


    def validity
      params.require(:id)
      params.require(:validity)
      @BagManRequest = BagManRequest.find(params[:id])
      @BagManRequest.update!(validity: params[:validity])
      render json: @BagManRequest, status: 200
    end


    def preserved
      params.require(:id)
      @BagManRequest = BagManRequest.find(params[:id])
      @BagManRequest.update!(status: :preserved)
      render json: @BagManRequest, status: 200
    end


    def cancel
      params.require(:id)
      @BagManRequest = BagManRequest.find(params[:id])
      @BagManRequest.update!(cancelled: true)
      render json: @BagManRequest, status: 200
    end


    def destroy
      params.require(:id)
      BagManRequest.destroy(params[:id])
      render nothing: true, status: 204
    end

  end
end