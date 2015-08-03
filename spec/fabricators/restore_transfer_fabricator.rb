# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:restore_transfer) do
  restore_id { Faker::Internet.password(7) }
  bag { Fabricate(:bag) }
  from_node { Fabricate(:node) }
  to_node { Fabricate(:node) }
  restore_status { Fabricate(:restore_status) }
  protocol { Fabricate(:protocol) }
  link { Faker::Internet.url }
end