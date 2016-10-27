# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class MessageDigestAdapter < ::AbstractAdapter
  map_date :created_at, :created_at
  map_simple :value, :value
  map_belongs_to :bag,        :bag,       sub_method: :uuid
  map_belongs_to :node,       :node,      sub_method: :namespace
  map_belongs_to :fixity_alg, :algorithm, sub_method: :name
end
