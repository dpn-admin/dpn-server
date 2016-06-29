# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe BagsController do

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
    it_behaves_like "a show endpoint", :uuid
  end


  describe "POST #create" do
    it_behaves_like "a create endpoint", :uuid
  end


  describe "PUT #update" do
    legal_update = proc {|record| record[:admin_node] = Fabricate(:node).namespace; record }
    illegal_update = proc {|record| record[:size] = 9182309182; record}

    context "without authentication" do
      before(:each) do
        put_body = adapter.from_model(Fabricate(:data_bag)).to_public_hash
        put :update, legal_update.call(put_body)
      end
      it_behaves_like "an unauthenticated request"
    end

    context "with authentication as non-local node" do
      include_context "with authentication"
      it_behaves_like "an unauthorized update", :uuid, nil, legal_update, illegal_update
    end

    context "with authentication as local node" do
      include_context "with local authentication"
      it_behaves_like "an authorized update", :uuid, nil, legal_update, illegal_update
    end
  end


  describe "DELETE #destroy" do
    it_behaves_like "a destroy endpoint", :uuid
  end

end
