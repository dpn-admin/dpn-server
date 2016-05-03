# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe ApiV2::MessageDigestsController do

  describe "GET #index" do
    context "without authentication" do
      before(:each) { get :index }
      it_behaves_like "an unauthenticated request"
    end
    context "with authentication" do
      include_context "with authentication"
      it_behaves_like "a paged endpoint", :get, :index, {}
      it_behaves_like "a queryable endpoint", :bag
    end
  end


  describe "GET #show" do
    it_behaves_like "a show endpoint", :uuid
  end


  describe "POST #create" do
    it_behaves_like "a create endpoint"
  end

end
