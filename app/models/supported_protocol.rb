# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class SupportedProtocol < ActiveRecord::Base
  belongs_to :protocol, inverse_of: :supported_protocols, touch: true
  belongs_to :node,     inverse_of: :supported_protocols, touch: true
  validates_uniqueness_of :node_id, scope: :protocol_id
end
