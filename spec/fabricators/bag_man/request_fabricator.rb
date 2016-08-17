# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:bag_man_request, class_name: "BagManRequest") do
  source_location { Faker::Internet.url }
  preservation_location nil
  last_step_completed :created
  last_error nil
  fixity nil
  cancelled false
  cancel_reason nil
  replication_transfer { Fabricate(:replication_transfer) }
end