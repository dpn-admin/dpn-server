# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:run_time) do
  name { Faker::Lorem.word }
  last_success { Faker::Time.between(DateTime.now - 10, DateTime.now ) }
end
