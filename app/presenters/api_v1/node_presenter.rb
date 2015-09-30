# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module ApiV1
  class NodePresenter
    def initialize(node)
      @node = node
    end

    def to_hash
      hash = {
        :namespace  => @node.namespace,
        :name       => @node.name,
        :api_root => @node.api_root,
        :ssh_pubkey => @node.ssh_pubkey,
        :storage => {
          :region => @node.storage_region ? @node.storage_region.name : nil,
          :type => @node.storage_type ? @node.storage_type.name : nil
        },
        :fixity_algorithms => @node.fixity_algs.pluck(:name),
        :protocols => @node.protocols.pluck(:name),
        :replicate_to => @node.replicate_to_nodes.pluck(:namespace),
        :replicate_from => @node.replicate_from_nodes.pluck(:namespace),
        :restore_to => @node.restore_to_nodes.pluck(:namespace),
        :restore_from => @node.restore_from_nodes.pluck(:namespace),
        :created_at => @node.created_at.to_formatted_s(:dpn),
        :updated_at => @node.updated_at.to_formatted_s(:dpn)
      }

      return hash
    end

    def to_json(options = {})
      return self.to_hash.to_json(options)
    end

    private
    attr_reader :node

  end
end
