# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'


module ApplicationHelper
  def controller_name
    "ApiV1::NodesController"
  end
  def action_name
    Rails.configuration.fake_action_name
  end
end

describe ApplicationHelper do

  describe "assignee" do
    context "index action" do
      before(:each) { Rails.configuration.fake_action_name = "index" }
      it "finds the plural symbol" do
        expect(assignee).to eql(:"@nodes")
      end
    end
    context "other action" do
      before(:each) { Rails.configuration.fake_action_name = "show" }
      it "finds the singular symbol" do
        expect(assignee).to eql(:"@node")
      end
    end
  end

  describe "model_name" do
    it "finds the correct model name" do
      expect(model_name).to eql("Node")
    end
  end

  describe "adapter" do
    it "finds the correct adapter" do
      expect(adapter).to eql(ApiV1::NodeAdapter)
    end
  end

end