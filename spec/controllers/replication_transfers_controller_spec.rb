# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'



describe ReplicationTransfersController do

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
    it_behaves_like "a show endpoint", :replication_id
  end


  describe "POST #create" do
    it_behaves_like "a create endpoint", :replication_id
  end


  describe "PUT #update" do
    legal_update = proc {|record| record[:status] = "cancelled"; record }
    illegal_update = proc {|record| record[:uuid] = SecureRandom.uuid; record }

    context "without authentication" do
      before(:each) {
        put_body = adapter.from_model(Fabricate(:replication_transfer)).to_public_hash
        put :update, legal_update.call(put_body)
      }
      it_behaves_like "an unauthenticated request"
    end

    context "with authentication as to_node" do
      include_context "with authentication as", "to_node_namespace"
      options = proc {
        {
          to_node: Node.find_by_namespace!("to_node_namespace"),
          from_node: Fabricate(:local_node)
        }
      }
      it_behaves_like "an authorized update", :replication_id, options, legal_update, illegal_update
    end

    context "with authentication as local node" do
      include_context "with local authentication"
      it_behaves_like "an authorized update", :replication_id, nil, legal_update, illegal_update
    end

    context "with authentication as unrelated node" do
      include_context "with authentication as", "some_other_node"
      it_behaves_like "an unauthorized update", :replication_id, nil, legal_update, illegal_update
    end

  end


  describe "DELETE #destroy" do
    it_behaves_like "a destroy endpoint", :replication_id
  end

end
