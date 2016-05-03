# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe "shared/errors.json.erb" do
  before(:each) do
    allow(ActionController::Metal).to receive(:controller_name).and_return(ApiV2::BagsController.controller_name)
    allow(ActionController::Metal).to receive(:controller_path).and_return(ApiV2::BagsController.controller_path)
    @bag = Fabricate.build(:data_bag, uuid: "herpderp", local_id: nil)
    assign(:bag, @bag)
    @bag.valid? # Populates the errors array, which we'll always call in practice.
    render
  end

  it "is json" do
    expect{
      JSON.parse(rendered)
    }.to_not raise_error
  end

  it "renders the full messages" do
    expect(JSON.parse(rendered)["errors"]).to eql(@bag.errors.full_messages)
  end

end