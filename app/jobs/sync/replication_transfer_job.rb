# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Sync
  class ReplicationTransferJob < JobMetal
    def perform(namespace)
      super("synchronize_replication_requests", namespace, QueryBuilder::ReplicationTransfer,
        ReplicationTransferAdapter, ReplicationTransfer)
    end
  end
end