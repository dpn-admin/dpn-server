# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Sync
    module QueryBuilder

      class Ingest

        def initialize(_ = nil, _ = nil)
        end


        # Build all of the queries for bags.
        # @param last_success [Time] The last time these items were synchronized.
        # @return [Array<Query>] The array of all queries that should be processed.
        def queries(last_success)
          [
            Query.new(:ingest, {
              after: last_success
            })
          ]
        end
      end

    end
  end
end
