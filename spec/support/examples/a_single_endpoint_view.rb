# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'



shared_examples "a single endpoint view" do
  before(:each) do
    allow(ActionController::Metal).to receive(:controller_name).and_return(ApiV1::NodesController.controller_name)
    allow(ActionController::Metal).to receive(:controller_path).and_return(ApiV1::NodesController.controller_path)
    @model = Fabricate(:node)
    assign(:node, @model)
    render
  end

  it "is json" do
    expect{
      JSON.parse(rendered)
    }.to_not raise_error
  end

  it "calls the adapter" do
    expect(rendered).to eql(ApiV1::NodeAdapter.from_model(@model).to_public_hash.to_json)
  end
end