# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:ingest) do
  ingest_id { SecureRandom.uuid }
  bag
  ingested { [true,false].sample }
  created_at 1.second.ago
end
