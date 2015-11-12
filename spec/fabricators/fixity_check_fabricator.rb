# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:fixity_check) do
  bag
  fixity_alg
  value { SecureRandom.uuid }
end
