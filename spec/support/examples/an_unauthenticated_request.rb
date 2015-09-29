# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

shared_examples "an unauthenticated request" do
  it "responds with 401" do
    expect(response).to have_http_status(401)
  end
  it "does not display data" do
    expect(response).to render_template(nil)
  end
end