# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module ApiV1
  class ReplicationTransferPresenter
    def initialize(repl)
      @repl = repl
    end

    def to_hash
      hash = {
        :replication_id => @repl.replication_id,
        :from_node => @repl.from_node.namespace,
        :to_node => @repl.to_node.namespace,
        :uuid => @repl.bag.uuid,
        :fixity_algorithm => @repl.fixity_alg.name,
        :fixity_nonce => @repl.fixity_nonce,
        :fixity_value => @repl.fixity_value,
        :fixity_accept => @repl.fixity_accept,
        :bag_valid => @repl.bag_valid,
        :status => @repl.replication_status.name,
        :protocol => @repl.protocol.name,
        :link => @repl.link,
        :created_at => @repl.created_at.to_formatted_s(:dpn),
        :updated_at => @repl.updated_at.to_formatted_s(:dpn)
      }
      return hash
    end

    def to_json(options = {})
      return self.to_hash.to_json(options)
    end

    private
    attr_reader :repl
  end
end