
module ApiV1
  class ReplicationTransferPresenter
    def initialize(repl)
      @repl = repl
    end

    def to_hash
      hash = {
        :repl_id => @repl.id,
        :from_node => @repl.from_node.namesapce,
        :to_node => @repl.to_node.namespace,
        :uuid => @repl.bag.uuid,
        :fixity_alg => @repl.fixity_alg.name,
        :fixity_nonce => @repl.fixity_nonce,
        :fixity_value => @repl.fixity_value,
        :fixity_accept => @repl.fixity_accept,
        :bag_valid => @repl.bag_valid,
        :status => @repl.replication_status.name,
        :protocol => @repl.protocol.name,
        :link => @repl.link,
        :created_at => @repl.created_at,
        :updated_at => @repl.updated_at
      }
      return hash
    end

    def to_json
      return self.to_hash.to_json
    end

    private
    attr_reader :repl
  end
end