# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module ApiV1
  class RestoreTransferPresenter
    def initialize(restore)
      @restore = restore
    end

    def to_hash
      hash = {
          :restore_id => @restore.restore_id,
          :from_node => @restore.from_node.namespace,
          :to_node => @restore.to_node.namespace,
          :uuid => @restore.bag.uuid,
          :protocol => @restore.protocol.name,
          :status => @restore.restore_status.name,
          :link => @restore.link,
          :created_at => @restore.created_at.to_formatted_s(:dpn),
          :updated_at => @restore.updated_at.to_formatted_s(:dpn)
      }
      return hash
    end

    def to_json(options = {})
      return self.to_hash.to_json(options)
    end

    private
    attr_reader :restore
  end
end