# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

shared_context "with local authentication" do
  before(:each) do
    node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
    @request.headers["Authorization"] = "Token token=#{node.auth_credential}"
  end
end