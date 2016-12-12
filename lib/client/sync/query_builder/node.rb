# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Sync
    module QueryBuilder
      class Node

        # @param remote_namespace [String] The namespace of the remote node
        def initialize(_ = nil, remote_namespace)
          @remote_namespace = remote_namespace
        end


        # Build all of the queries.
        # @return [Array<Query>] The array of all queries that should be processed.
        def queries(last_success = nil)
          [Query.new(:node, @remote_namespace)]
        end
      end

    end
  end
end