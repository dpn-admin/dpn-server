# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:message_digest) do
  bag
  node
  fixity_alg
  value { SecureRandom.uuid }
  created_at 1.second.ago
end
