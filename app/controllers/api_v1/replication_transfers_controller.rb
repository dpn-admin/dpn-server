require_relative '../../../app/presenters/api_v1/replication_transfer_presenter'

class ApiV1::ReplicationTransfersController < ApplicationController
  def index
    transfers = ReplicationTransfer.all.collect do |transfer|
      ApiV1::ReplicationTransferPresenter.new(transfer)
    end

    output = {
      :count => transfers.size,
      :results => transfers
    }

    render json: output
  end

  def show
    transfer = ReplicationTransfer.find(params[:id])
    render json: ReplicationTransferPresenter.new(transfer)
  end
end
