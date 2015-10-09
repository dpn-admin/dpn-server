require 'rails_helper'

describe ApiV1::MembersController do

  describe "GET #index" do
    context "without authentication" do
      before(:each) { get :index }
      it_behaves_like "an unauthenticated request"
    end
    context "with authentication" do
      include_context "with authentication"
      it_behaves_like "a paged endpoint", :get, :index, {}
      it_behaves_like "a queryable endpoint", :name
      it_behaves_like "a queryable endpoint", :email
    end
  end


  describe "GET #show" do
    it_behaves_like "a show endpoint", :uuid
  end


  describe "POST #create" do
    it_behaves_like "a create endpoint", :uuid
  end


  describe "PUT #update" do
    legal_update = proc {|record| record[:email] = Faker::Internet.email; record }
    illegal_update = proc {|record| record[:email] = nil; record}

    context "without authentication" do
      before(:each) do
        put_body = adapter.from_model(Fabricate(:member)).to_public_hash
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
