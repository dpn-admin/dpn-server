# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe FixityChecksController do

  describe "GET #index" do
    context "without authentication" do
      before(:each) { get :index }
      it_behaves_like "an unauthenticated request"
    end
    context "with authentication" do
      include_context "with authentication"
      it_behaves_like "a paged endpoint", :get, :index, {}
    end
  end


  describe "POST #create" do
    before(:each) do
      @some_bag = Fabricate(:bag)
      @some_node = Fabricate(:node)
    end
    it_behaves_like "a create endpoint" do
      let!(:invalid_post_body) do # missing node
        {
          fixity_check_id: "7998e960-fc6d-44f4-9d73-9a60a8eae609",
          bag: @some_bag.uuid,
          success: true,
          fixity_at: "2016-05-03T19:25:57Z",
          created_at: "2016-05-03T19:25:57Z"
        }
      end
    end
  end

end
