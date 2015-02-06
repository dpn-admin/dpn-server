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

  # This method is internal
  def create
    transfer = ReplicationTransfer.new
    transfer.id = params[:replication_transfer][:repl_id]
    transfer.from_node = Node.find_by_namespace(params[:replication_transfer][:from_node])
    transfer.to_node = Node.find_by_namespace(params[:replication_transfer][:to_node])
    transfer.bag = Bag.find_by_uuid(params[:replication_transfer][:uuid])
    transfer.fixity_alg = FixityAlg.find_by_name(params[:replication_transfer][:fixity_alg])
    transfer.fixity_nonce = params[:replication_transfer][:fixity_nonce]
    transfer.fixity_value = params[:replication_transfer][:fixity_value]
    transfer.fixity_accept = params[:replication_transfer][:fixity_accept]
    transfer.bag_valid = params[:replication_transfer][:bag_valid]
    transfer.replication_status = ReplicationStatus.find_by_name(params[:replication_transfer][:status])
    transfer.protocol = Protocol.find_by_name(params[:replication_transfer][:protocol])
    transfer.link = params[:replication_transfer][:link]
    transfer.save
    render json: ReplicationTransferPresenter.new(transfer)
  end

  def update
    transfer = ReplicationTransfer.find(params[:id])
    old_status = transfer.replication_status.name.downcase.to_sym
    new_status = params[:replication_transfer][:status].downcase.to_sym

    if old_status == new_status
      # do nothing
      render json: ReplicationTransferPresenter.new(transfer) and return
    end

    case [old_status, new_status]
    when [:requested, :rejected]
      transfer.replication_status = ReplicationStatus.find_by_name(new_status)
    when [:requested, :received]
      transfer.replication_status = ReplicationStatus.find_by_name(new_status)
      transfer.fixity_value = params[:replication_transfer][:fixity_value]
      transfer.bag_valid = params[:replication_transfer][:bag_valid]
    when [:requested, :cancelled]
      transfer.replication_status = ReplicationStatus.find_by_name(new_status)
    when [:received, :confirmed]
      transfer.replication_status = ReplicationStatus.find_by_name(new_status)
      transfer.fixity_accept = params[:replication_transfer][:fixity_accept]
    when [:received, :cancelled]
      transfer.replication_status = ReplicationStatus.find_by_name(new_status)
      transfer.bag_valid = params[:replication_transfer][:bag_valid]
    else
      # Everything else is illegal.
      throw TypeError, "not allowed"
    end

    transfer.save # TODO: check if dirty
    render json: ReplicationTransferPresenter.new(transfer)
  end

end
