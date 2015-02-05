
module ApiV1
  class NodePresenter
    def initialize(node)
      @node = node
      @hash = nil
    end

    def to_hash
      if @hash != nil
        return @hash
      end

      @hash = {
        :namespace  => @node.namespace,
        :name       => @node.name,
        :ssh_pubkey => @node.ssh_pubkey,
        :storage => {
          :region => @node.storage_region.name,
          :type => @node.storage_type.name
        },
        :fixity_algs => @node.fixity_algs.pluck(:name),
        :protocols => @node.protocols.pluck(:name),
        :replicate_to => @node.to_nodes.pluck(:namespace),
        :replicate_from => @node.from_nodes.pluck(:namespace),
        :created_at => @node.created_at,
        :updated_at => @node.updated_at
      }



      return @hash
    end

    def to_json(options = {})
      return self.to_hash.to_json
    end

    private
    attr_reader :node, :hash

  end
end
