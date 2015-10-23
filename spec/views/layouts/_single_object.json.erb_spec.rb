# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

module ApplicationHelper
  def controller_name
    "ApiV1::NodesController"
  end
end

describe "application/_single_object.json.erb" do
  before(:each) do
    @model = Fabricate(:node)
    render partial: "single_object", object: @model
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