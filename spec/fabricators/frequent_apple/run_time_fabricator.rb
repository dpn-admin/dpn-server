# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:frequent_apple_run_time, class_name: "FrequentApple::RunTime") do
  name { Faker::Internet.user_name }
  namespace { Fabricate(:node).namespace }
  last_run_time nil
end