# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe ApiV2::NodesController do

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


  describe "GET #show" do
    it_behaves_like "a show endpoint", :namespace
  end


  describe "POST #create" do
    extra_params = [:private_auth_token, :auth_credential]
    it_behaves_like "a create endpoint", :namespace, extra_params
  end


  describe "PUT #update" do
    legal_update = proc {|record| record[:name] = "some_new_name"; record }
    illegal_update = proc {|record| record[:name] = nil; record}

    context "without authentication" do
      before(:each) do
        put_body = adapter.from_model(Fabricate(:node)).to_public_hash
        put :update, legal_update.call(put_body)
      end
      it_behaves_like "an unauthenticated request"
    end

    context "with authentication as non-local node" do
      include_context "with authentication"
      it_behaves_like "an unauthorized update", :namespace, nil, legal_update, illegal_update
    end

    context "with authentication as local node" do
      include_context "with local authentication"
      it_behaves_like "an authorized update", :namespace, nil, legal_update, illegal_update
    end
  end


  describe "DELETE #destroy" do
    it_behaves_like "a destroy endpoint", :namespace
  end

end

