# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:fixity_alg) do
  name { Faker::Internet.password(10, 20) }
  created_at 1.month.ago
  updated_at 1.month.ago
end