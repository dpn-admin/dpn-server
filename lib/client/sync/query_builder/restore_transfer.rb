# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Sync
    module QueryBuilder
      class RestoreTransfer

        # @param remote_namespace [String] The namespace of the remote node
        def initialize(_ = nil, remote_namespace)
          @remote_namespace = remote_namespace
        end


        # Build all of the queries for bags.
        # @param last_success [Time] The last time these items were synchronized.
        # @return [Array<Query>] The array of all queries that should be processed.
        def queries(last_success)
          [
            Query.new(:restore, {
              to_node: @remote_namespace,
              after: last_success
            })
          ]
        end
      end

    end
  end
end