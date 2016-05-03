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
      #it_behaves_like "a queryable endpoint", :bag
    end
  end


  describe "GET #show" do
    context "without authentication" do
      before(:each) do
        instance = Fabricate(:message_digest)        
        get :show, { bag: instance.bag.uuid, algorithm: instance.fixity_alg.name }
      end
      it_behaves_like "an unauthenticated request"
    end

    context "with authentication" do
      include_context "with authentication"
      before(:each) { @instance = Fabricate(factory) }

      context "record doesn't exist" do
        before(:each) do
          get :show, { bag: @instance.bag.uuid, algorithm: Fabricate(:fixity_alg).name }
        end
        it "responds with 404" do
          expect(response).to have_http_status(404)
        end
        it "renders nothing" do
          expect(response).to render_template(nil)
        end
      end

      context "record exists" do
        before(:each) do
          get :show, { bag: @instance.bag.uuid, algorithm: @instance.fixity_alg.name }
        end

        it "responds with 200" do
          expect(response).to have_http_status(200)
        end
        it "assigns the correct object to @#{factory}" do
          expect(assigns(factory)).to_not be_nil
          expect(assigns(factory)).to be_a model_class
          expect(assigns(factory).attributes["value"]).to eql(@instance.public_send(:value))
        end
        it "renders json" do
          expect(response.content_type).to eql("application/json")
        end
        it "renders the show template" do
          expect(response).to render_template(:show)
        end
      end
    end
  end


  describe "POST #create" do
    before(:each) do 
      @some_bag = Fabricate(:bag)
      @some_fixity_alg = Fabricate(:fixity_alg)
    end
    it_behaves_like "a create endpoint" do
      let!(:invalid_post_body) {
        {
          created_at: "2016-05-03T19:25:57Z",
          bag: @some_bag.uuid,
          algorithm: @some_fixity_alg.name
        }  
      }
    end
  end

end
