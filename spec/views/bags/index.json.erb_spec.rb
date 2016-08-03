# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe "bags/index.json.erb" do
  before(:each) do
    allow(ActionController::Metal).to receive(:controller_name).and_return(BagsController.controller_name)
    allow(ActionController::Metal).to receive(:controller_path).and_return(BagsController.controller_path)
    controller.action_name = "index"
    params[:controller] = :bags

    Fabricate.times(5, :data_bag, size: 10001)
    @bags = Bag.all.page(1).per(3)
    assign(:bags, @bags)
    params[:page_size] = 3
    render
  end

  it "is json" do
    expect{
      JSON.parse(rendered)
    }.to_not raise_error
  end

  it "renders total_size" do
    json = JSON.parse(rendered)
    expect(json).to have_key "total_size"
    expect(json["total_size"]).to eql(50005)
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
        controller: :bags,
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
    expected_array = @bags.map do |bag|
      BagAdapter.from_model(bag).to_public_hash
    end
    # The extra conversion here handles any nesting.
    expect(json["results"]).to match_array(JSON.parse(expected_array.to_json))
  end

end