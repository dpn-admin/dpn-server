# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:restore_status) do
  name do
    sequence(:name, 50) do |i|
      "restore_status_#{i}"
    end
  end
end