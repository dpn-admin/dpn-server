# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:restore_transfer) do
  restore_id { SecureRandom.uuid }
  bag { Fabricate(:bag) }
  from_node { Fabricate(:node) }
  to_node { Fabricate(:node) }
  status :requested
  protocol { Fabricate(:protocol) }
  link { Faker::Internet.url }
  created_at 1.month.ago
  updated_at 1.month.ago
end