# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

shared_context "with authentication" do
  include_context "with authentication as", Faker::Lorem.word.downcase
end