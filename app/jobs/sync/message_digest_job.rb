# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Sync
  class MessageDigestJob < JobMetal
    def perform(namespace)
      super("synchronize_digests", namespace, QueryBuilder::MessageDigest,
        MessageDigestAdapter, MessageDigest)
    end
  end
end