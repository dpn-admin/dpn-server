# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Sync
  class FixityCheckJob < JobMetal
    def perform(namespace)
      super("synchronize_fixity_checks", namespace, QueryBuilder::FixityCheck,
        FixityCheckAdapter, FixityCheck)
    end
  end
end