# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:fixity_check) do
  fixity_check_id { SecureRandom.uuid }
  bag
  node
  success true
  fixity_at 3.seconds.ago
  created_at 1.second.ago
end
