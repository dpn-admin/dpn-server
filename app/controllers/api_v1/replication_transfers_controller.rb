# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require_relative '../../../app/presenters/api_v1/replication_transfer_presenter'

class ApiV1::ReplicationTransfersController < ApplicationController
  include Authenticate
  include Pagination

  local_node_only :create, :destroy
  uses_pagination :index

  before_action :accept_newer_only, only: :update

  def index
    conditions = {}
    join_tables = []

    if params[:uuid]
      bag = Bag.find_by_uuid(params[:uuid])
      if bag.blank?
        conditions[:bag_id] = nil
      else
        conditions[:bag_id] = bag.id
      end
    end

    if params[:status]
      join_tables.push :replication_status
      conditions[:replication_statuses] = {name: params[:status].downcase}
    end

    if params[:fixity_accept]
      case params[:fixity_accept].downcase
        when "true"
          conditions[:fixity_accept] = true
        when "false"
          conditions[:fixity_accept] = false
        when "null"
          conditions[:fixity_accept] = nil
        else
          render nothing: true, status: 400 and return
      end
    end

    if params[:bag_valid]
      case params[:bag_valid].downcase
        when "true"
          conditions[:bag_valid] = true
        when "false"
          conditions[:bag_valid] = false
        when "null"
          conditions[:bag_valid] = nil
        else
          render nothing: true, status: 400 and return
      end
    end

    before_time = nil
    after_time = nil
    begin
      if params[:before]
        before_time = DateTime.strptime(params[:before], Time::DATE_FORMATS[:dpn])
      end
      if params[:after]
        after_time = DateTime.strptime(params[:after], Time::DATE_FORMATS[:dpn])
      end
    rescue ArgumentError
      render json: "Bad parameters", status: 400 and return
    end

    range_clause = nil
    if before_time && after_time
      range_clause = ["#{ReplicationTransfer.table_name}.updated_at", after_time..before_time]
    elsif before_time
      range_clause = ["#{ReplicationTransfer.table_name}.updated_at <= ?", before_time]
    elsif after_time
      range_clause = ["#{ReplicationTransfer.table_name}.updated_at >= ?", after_time]
    end

    ordering = {updated_at: :desc}
    if params[:order_by]
      new_ordering = {}
      params[:order_by].split(',').each do |order_column|
        if [:created_at, :updated_at].include?(order_column.to_sym)
          new_ordering[order_column.to_sym] = :desc
        end
      end
      ordering = new_ordering unless new_ordering.empty?
    end

    if params[:to_node]
      to_node = Node.find_by_namespace(params[:to_node])
      if to_node.blank?
        conditions[:to_node] = nil
      else
        conditions[:to_node] = to_node.id
      end
    end

    if params[:from_node]
      from_node = Node.find_by_namespace(params[:from_node])
      if from_node.blank?
        conditions[:from_node] = nil
      else
        conditions[:from_node] = from_node.id
      end
    end

    if range_clause
      raw_transfers = ReplicationTransfer.joins(join_tables).where(conditions).where(range_clause).order(ordering).page(@page).per(@page_size)
    else
      raw_transfers = ReplicationTransfer.joins(join_tables).where(conditions).order(ordering).page(@page).per(@page_size)

    end

    @replication_transfers = raw_transfers.collect do |transfer|
      ApiV1::ReplicationTransferPresenter.new(transfer)
    end

    total_records = ReplicationTransfer.joins(join_tables).where(conditions).count
    next_link = link_to_next_page(raw_transfers.total_count) if total_records > (@page * @page_size)

    output = {
      :count => @replication_transfers.size,
      :next => next_link,
      :previous => link_to_previous_page,
      :results => @replication_transfers
    }

    render json: output, status: 200
  end


  def show
    repl = ReplicationTransfer.find_by_replication_id!(params[:replication_id])
    @replication_transfer = ApiV1::ReplicationTransferPresenter.new(repl)
    render json: @replication_transfer, status: 200
  end


  # This method is internal
  def create
    transfer = ReplicationTransfer.new
    transfer.replication_id = params[:replication_id]
    transfer.from_node = Node.find_by_namespace(params[:from_node])
    transfer.to_node = Node.find_by_namespace(params[:to_node])
    transfer.bag = Bag.find_by_uuid(params[:uuid])
    transfer.fixity_alg = FixityAlg.find_by_name(params[:fixity_algorithm])
    transfer.fixity_nonce = params[:fixity_nonce]
    transfer.fixity_value = params[:fixity_value]
    transfer.fixity_accept = params[:fixity_accept]
    transfer.bag_valid = params[:bag_valid]
    transfer.replication_status = ReplicationStatus.find_by_name(params[:status])
    transfer.protocol = Protocol.find_by_name(params[:protocol])
    transfer.link = params[:link]

    if transfer.save
      BagManRequest.create!(source_location: transfer.link, cancelled: false)
      @replication_transfer = ApiV1::ReplicationTransferPresenter.new(transfer)
      render json: @replication_transfer, content_type: "application/json", status: 201
    else
      render json: transfer.errors, content_type: "application/json", status: 400
    end
  end


  # This method is external
  def update
    expected_params = [:replication_id, :from_node, :to_node,
      :uuid, :fixity_algorithm, :fixity_nonce, :fixity_value,
      :fixity_accept, :bag_valid, :status, :protocol, :link,
      :created_at, :updated_at
    ]

    missing_params = expected_params - params.to_unsafe_hash.keys.map {|key| key.to_sym}
    if missing_params.count > 0
      err_message = "Record is missing parameters #{missing_params.join(', ')}"
      render json: { params: [ err_message ] }, content_type: "application/json", status: 400
      return
    end

    transfer = ReplicationTransfer.find_by_replication_id!(params[:replication_id])

    old_status = transfer.replication_status.name.downcase.to_sym
    new_status = params[:status].downcase.to_sym

    local_namespace = Rails.configuration.local_namespace
    if @requester.namespace == local_namespace
      from = :us
    elsif @requester.namespace == params[:to_node]
      from = :to_node
    else
      render json: { forbidden: ['Your node has no part in this transfer'] }, status: 403 and return
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
      render json: { forbidden: ['Your node has no part in this transfer'] }, status: 403 and return
    end

    # TODO: Do not accept fixity_accept from an external caller
    # if we are the from_node. See https://jira.duraspace.org/browse/DPN-56

    # TODO: Should we allow params to_node and from_node in the request?
    # Those should never change once a request is created. Same probably
    # goes for uuid, fixity_algorithm, fixity_nonce, protocol, link,
    # and created_at. We can updated updated_at internally, so maybe
    # no need for that param either.

    spawn_bag_preserve_job = false
    # requester | local_node's role | old status | new status
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
        spawn_bag_preserve_job = true
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
        # Not sure I can unwind this logic to figure out what went wrong.
        # Let's just tell the user we hate them.
        render json: { error: ["The big switch statement didn't like your data"] }, status: 400 and return
    end

    transfer.replication_status = ReplicationStatus.find_by_name(new_status)
    if transfer.save
      if spawn_bag_preserve_job
        bag_man_request = BagManRequest.find(transfer.bag_man_request_id)
        ::BagMan::BagPreserveJob.perform_later(bag_man_request, bag_man_request.staging_location, Rails.configuration.repo_dir)
      end
      render json: ApiV1::ReplicationTransferPresenter.new(transfer)
    else
      render json: transfer.errors, content_type: "application/json", status: 400
    end

  end


  # This method is internal
  # This method is for testing purposes only.
  def destroy
    if Rails.env.production?
      render nothing: true, status: 403 and return
    end

    repl = ReplicationTransfer.find_by_replication_id!(params[:replication_id])
    repl.destroy!
    render nothing: true, status: 204
  end


  protected
  def accept_newer_only
    repl = ReplicationTransfer.find_by_replication_id!(params[:replication_id])

    if params[:updated_at] < repl.updated_at
      render json: { updated_at: ["Body describes an old record"] }, status: 400 and return
    end
  end

end
