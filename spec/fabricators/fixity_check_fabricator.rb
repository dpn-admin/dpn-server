# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:fixity_check) do
  fixity_check_id { SecureRandom.uuid }
  bag
  node
  success true
  created_at 1.second.ago

  # fixity_at must be at the same time or before created_at
  fixity_at {|attrs| (attrs[:created_at] || 1.second.ago) - 3.seconds}
end
