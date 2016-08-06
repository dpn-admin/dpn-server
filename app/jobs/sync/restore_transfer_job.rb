# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Sync
  class RestoreTransferJob < JobMetal
    def perform(namespace)
      super("synchronize_restore_requests", namespace,
        QueryBuilder::RestoreTransfer,
        RestoreTransferAdapter, RestoreTransfer)
    end
  end
end