# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class MemberAdapter < ::AbstractAdapter
  map_simple :uuid, :uuid
  map_simple :name, :name
  map_simple :email, :email
end