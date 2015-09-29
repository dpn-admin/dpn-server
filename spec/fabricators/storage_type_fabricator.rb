# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:storage_type) do
  name do
    sequence(:name, 50) do |i|
      "storage_type_#{i}"
    end
  end
  created_at 1.second.ago
  updated_at 1.second.ago
end