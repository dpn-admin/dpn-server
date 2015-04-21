require_relative '../../../app/presenters/api_v1/replication_transfer_presenter'

class ApiV1::ReplicationTransfersController < ApplicationController
  include Authenticate

  def index
    @replication_transfers = ReplicationTransfer.all.collect do |transfer|
      ApiV1::ReplicationTransferPresenter.new(transfer)
    end

    output = {
      :count => @replication_transfers.size,
      :results => @replication_transfers
    }

    render json: output, status: 200
  end

  def show
    repl = ReplicationTransfer.find_by_replication_id(params[:replication_id])
    if repl.nil?
      render nothing: true, status: 404
    else
      @replication_transfer = ApiV1::ReplicationTransferPresenter.new(repl)
      render json: @replication_transfer, status: 200
    end
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
    render json: ApiV1::ReplicationTransferPresenter.new(transfer)
  end


  # This method is external
  def update
    expected_params = [:replication_id, :from_node, :to_node,
      :uuid, :fixity_algorithm, :fixity_nonce, :fixity_value,
      :fixity_accept, :bag_valid, :status, :protocol, :link,
      :created_at, :updated_at
    ]

    unless expected_params.all? { |param| params.has_key?(param)}
      render nothing: true, status: 400
      return
    end

    transfer = ReplicationTransfer.find_by_replication_id(params[:replication_id])
    if transfer.nil?
      render nothing: true, status: 404
      return
    end

    old_status = transfer.replication_status.name.downcase.to_sym
    new_status = params[:status].downcase.to_sym

    local_namespace = Rails.configuration.local_namespace
    if @requester.namespace == local_namespace
      from = :us
    elsif @requester.namespace == params[:to_node]
      from = :to_node
    else
      render nothing: true, status: 403
      return
    end

    case local_namespace
      when transfer.from_node.namespace
        role = :from_node
      when transfer.to_node.namespace
        role = :to_node
      else
        role = :none
    end

    if from == :to_node && role == :none
      render nothing: true, status: 403
      return
    end

    if old_status == new_status # do nothing
      render nothing: true, status: 400
      return
    end

    case [from, role, old_status, new_status]
      when [:us, :from_node, :requested, :cancelled]
        transfer.bag_valid = params[:bag_valid]
      when [:us, :from_node, :received, :confirmed]
        transfer.fixity_accept = params[:fixity_accept]
      when [:us, :from_node, :received, :cancelled]
        transfer.fixity_accept = params[:fixity_accept]
      when [:us, :from_node, :confirmed, :cancelled]
      when [:us, :to_node, :requested, :rejected]
      when [:us, :to_node, :requested, :received]
        transfer.fixity_value = params[:fixity_value]
        transfer.bag_valid = params[:bag_valid]
      when [:us, :to_node, :requested, :confirmed]
        transfer.fixity_accept = params[:fixity_accept]
        transfer.fixity_value = params[:fixity_value]
        transfer.bag_valid = params[:bag_valid]
      when [:us, :to_node, :requested, :cancelled]
        transfer.bag_valid = params[:bag_valid]
      when [:us, :to_node, :received, :confirmed]
        transfer.fixity_accept = params[:fixity_accept]
      when [:us, :to_node, :received, :cancelled]
        transfer.fixity_accept = params[:fixity_accept]
      when [:us, :to_node, :confirmed, :cancelled]
      when [:us, :to_node, :confirmed, :stored]
      when [:us, :none, :requested, :rejected]
      when [:us, :none, :requested, :received]
        transfer.fixity_value = params[:fixity_value]
        transfer.bag_valid = params[:bag_valid]
      when [:us, :none, :requested, :confirmed]
        transfer.fixity_accept = params[:fixity_accept]
        transfer.fixity_value = params[:fixity_value]
        transfer.bag_valid = params[:bag_valid]
      when [:us, :none, :requested, :stored]
        transfer.fixity_accept = params[:fixity_accept]
        transfer.fixity_value = params[:fixity_value]
        transfer.bag_valid = params[:bag_valid]
      when [:us, :none, :requested, :cancelled]
        transfer.fixity_accept = params[:fixity_accept]
        transfer.fixity_value = params[:fixity_value]
        transfer.bag_valid = params[:bag_valid]
      when [:us, :none, :received, :confirmed]
        transfer.fixity_accept = params[:fixity_accept]
      when [:us, :none, :received, :cancelled]
        transfer.fixity_accept = params[:fixity_accept]
      when [:us, :none, :received, :stored]
        transfer.fixity_accept = params[:fixity_accept]
      when [:us, :none, :confirmed, :cancelled]
      when [:us, :none, :confirmed, :stored]
      when [:to_node, :from_node, :requested, :rejected]
      when [:to_node, :from_node, :requested, :received]
        transfer.fixity_value = params[:fixity_value]
        transfer.bag_valid = params[:bag_valid]
      when [:to_node, :from_node, :requested, :cancelled]
        transfer.bag_valid = params[:bag_valid]
      when [:to_node, :from_node, :received, :cancelled]
      when [:to_node, :from_node, :confirmed, :stored]
      when [:to_node, :from_node, :confirmed, :cancelled]
      else
        render nothing: true, status: 400
        return
    end

    transfer.replication_status = ReplicationStatus.find_by_name(new_status)
    if transfer.save
      render json: ApiV1::ReplicationTransferPresenter.new(transfer)
    else
      render nothing: true, status: 400
    end

  end

end
