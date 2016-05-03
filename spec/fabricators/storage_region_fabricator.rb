# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:storage_region) do
  name { sequence(:storage_region_name) { |n| "#{Faker::Address.state_abbr}#{n}"} }
  created_at 1.second.ago
  updated_at 1.second.ago
end