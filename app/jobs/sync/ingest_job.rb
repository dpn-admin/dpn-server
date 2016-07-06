# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Sync
  class IngestJob < JobMetal
    def perform(namespace)
      super("synchronize_ingests", namespace, QueryBuilder::Ingest, IngestAdapter, Ingest)
    end
  end
end