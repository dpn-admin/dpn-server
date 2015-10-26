# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

shared_examples "a show endpoint" do |key|
  context "without authentication" do
    before(:each) { get :show, key => Fabricate(factory).send(key) }
    it_behaves_like "an unauthenticated request"
  end

  context "with authentication" do
    include_context "with authentication"
    before(:each) { @instance = Fabricate(factory) }

    context "record doesn't exist" do
      before(:each) { get :show, key => SecureRandom.uuid }
      it "responds with 404" do
        expect(response).to have_http_status(404)
      end
      it "renders nothing" do
        expect(response).to render_template(nil)
      end
    end

    context "record exists" do
      before(:each) { get :show, key => @instance.public_send(key) }

      it "responds with 200" do
        expect(response).to have_http_status(200)
      end
      it "assigns the correct object to @#{factory}" do
        expect(assigns(factory)).to_not be_nil
        expect(assigns(factory)).to be_a model_class
        expect(assigns(factory).attributes[key.to_s]).to eql(@instance.public_send(key))
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

