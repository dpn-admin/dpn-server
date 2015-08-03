# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class VersionFamily < ActiveRecord::Base
  has_many :bags, :inverse_of => :version_family

  include Lowercased
  make_lowercased :uuid

end