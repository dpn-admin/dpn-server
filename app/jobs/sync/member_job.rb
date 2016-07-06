# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Sync
  class MemberJob < JobMetal
    def perform(namespace)
      super("synchronize_members", namespace, QueryBuilder::Member, MemberAdapter, Member)
    end
  end
end