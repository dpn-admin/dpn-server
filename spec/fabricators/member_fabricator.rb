# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

Fabricator(:member) do
  uuid { SecureRandom.uuid }
  name { Faker::Company.name }
  email { Faker::Internet.email }
end
