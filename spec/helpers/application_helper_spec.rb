# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe ApplicationHelper do
  before(:each) do
    allow(ActionController::Metal).to receive(:controller_name).and_return(ApiV2::NodesController.controller_name)
    allow(ActionController::Metal).to receive(:controller_path).and_return(ApiV2::NodesController.controller_path)
  end

  describe "assignee" do
    context "index action" do
      before(:each) { controller.action_name = "index" }
      it "finds the plural symbol" do
        expect(assignee).to eql(:"@nodes")
      end
    end
    context "other action" do
      before(:each) { controller.action_name = "show" }
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
      expect(adapter).to eql(ApiV2::NodeAdapter)
    end
  end

end