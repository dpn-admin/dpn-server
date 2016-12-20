# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class ReplicationTransferUpdater

  class << self
    def update(record, params)
      build_update(record, params).update
    end

    def build_update(record, params)
      case
      when CancelUpdate.matching_update?(record, params)
        CancelUpdate.new(record, params)
      when FixityValueUpdate.matching_update?(record, params)
        FixityValueUpdate.new(record, params)
      when StoreRequestedUpdate.matching_update?(record, params)
        StoreRequestedUpdate.new(record, params)
      when StoredUpdate.matching_update?(record, params)
        StoredUpdate.new(record, params)
      else
        ReplicationTransferUpdate.new(record, params)
      end
    end

  end


  # A generic update
  class ReplicationTransferUpdate

    # @param [ReplicationTransfer] record
    # @param [HashWithIndifferentAccess] params The params hash of the update
    def initialize(record, params)
      @record = record
      @params = params
    end
    def update
      record.update(params)
    end
    def we_requested?
      record.from_node&.local_node?
    end
    def we_replicating?
      record.to_node&.local_node?
    end

    private
    attr_reader :record, :params
  end


  # An update in which the request is cancelling the record
  class CancelUpdate < ReplicationTransferUpdate
    def self.matching_update?(record, params)
      record.cancelled == false && params[:cancelled] == true
    end
    def update
      record.cancel!(params[:cancel_reason], params[:cancel_reason_detail])
    end
  end


  # An update in which the request sets fixity_value
  class FixityValueUpdate < ReplicationTransferUpdate
    def self.matching_update?(record, params)
      record.fixity_value.nil? && params[:fixity_value] != nil
    end

    def update
      result = record.update(params)
      if result && we_requested?
        request_storage
      end
      return result
    end

    private

    def request_storage
      if params[:fixity_value] == correct_fixity
        record.update(store_requested: true)
      else
        detail = "expected: '#{correct_fixity}', got: '#{params[:fixity_value]}'"
        record.cancel!("fixity_reject", detail)
      end
    end

    def correct_fixity
      @correct_fixity ||= record.bag.message_digests.where(fixity_alg_id: record.fixity_alg_id).first.value
    end
  end


  # An update in which the request sets store_requested
  class StoreRequestedUpdate < ReplicationTransferUpdate
    def self.matching_update?(record, params)
      record.store_requested == false && params[:store_requested] == true
    end

    def update
      record.update(params)
    end
  end


  # An update in which the request sets stored
  class StoredUpdate < ReplicationTransferUpdate
    def self.matching_update?(record, params)
      record.stored == false && params[:stored] == true
    end

    def update
      result = record.update(params)
      if result && we_requested?
        add_replicating_node
      end
      return result
    end

    private

    def add_replicating_node
      record.bag.replicating_nodes << record.to_node
    end

  end


end
