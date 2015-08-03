# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


RSpec::Matchers.define :match_without_timestamps do |expected|
  match do |actual|
    actual.reject! { |k,v| [:updated_at, :created_at].include? k }
    expected.reject! { |k,v| [:updated_at, :created_at].include? k }
    actual == expected
  end

  diffable
end