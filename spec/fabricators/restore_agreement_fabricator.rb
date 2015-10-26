# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:restore_agreement) do
  from_node { Fabricate(:node) }
  to_node { Fabricate(:node) }
  created_at 1.second.ago
  updated_at 1.second.ago
end