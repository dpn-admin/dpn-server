# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe "shared/index.json.erb" do
  before(:each) do
    allow(ActionController::Metal).to receive(:controller_name).and_return("ApiV1::NodesController")
    controller.action_name = "index"
    params[:controller] = "api_v1/nodes"

    Fabricate.times(5, :node)
    @nodes = Node.all.page(1).per(3)
    assign(:nodes, @nodes)
    params[:page_size] = 3
    render
  end

  it "is json" do
    expect{
      JSON.parse(rendered)
    }.to_not raise_error
  end

  it "renders count" do
    json = JSON.parse(rendered)
    expect(json).to have_key "count"
    expect(json["count"]).to eql(5)
  end

  it "renders next" do
    json = JSON.parse(rendered)
    expect(json).to have_key "next"
    url = url_for(
      controller: "api_v1/nodes",
      action: "index",
      page: 2,
      page_size: 3
    )
    expect(json["next"]).to eql(url)
  end

  it "renders previous" do
    json = JSON.parse(rendered)
    expect(json).to have_key "previous"
    expect(json["previous"]).to eql(nil)
  end

  it "renders multiple results" do
    json = JSON.parse(rendered)
    expect(json).to have_key "results"
    expect(json["results"]).to respond_to(:size)
    expect(json["results"].size).to eql(3)
  end

  it "renders the results correctly" do
    json = JSON.parse(rendered)
    expect(json).to have_key "results"
    expected_array = @nodes.map do |node|
      ApiV1::NodeAdapter.from_model(node).to_public_hash
    end
    # The extra conversion here handles any nesting.
    expect(json["results"]).to match_array(JSON.parse(expected_array.to_json))
  end

end