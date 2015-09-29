# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

shared_context "with authentication as" do |namespace|
  before(:each) do
    token = Faker::Code.isbn
    @node = Fabricate(:node, namespace: namespace, private_auth_token: token)
    @request.headers["Authorization"] = "Token token=#{token}"
  end
end