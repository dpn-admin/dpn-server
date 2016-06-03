# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

shared_examples "a create endpoint" do |key, extra_params|
  extra_params ||= []

  def body_from_instance(instance, extra_params)
    body = adapter.from_model(instance).to_public_hash
    extra_params.each do |param|
      body[param] = instance.send(param)
    end
    return body
  end


  before(:each) do
    @request.headers["Content-Type"] = "application/json"
  end

  context "without authentication" do
    before(:each) do
      instance = Fabricate(factory)
      post_body = body_from_instance(instance, extra_params)
      model_class.delete(instance.id)
      @number_of_records = model_class.count
      post :create, post_body
    end
    it_behaves_like "an unauthenticated request"
    it "does not create the record" do
      expect(model_class.count).to eql(@number_of_records)
    end
  end

  context "with authentication" do
    include_context "with authentication"
    before(:each) do
      instance = Fabricate(factory)
      post_body = body_from_instance(instance, extra_params)
      model_class.delete(instance.id)
      @number_of_records = model_class.count
      post :create, post_body
    end
    it_behaves_like "an unauthorized request"
    it "does not create the record" do
      expect(model_class.count).to eql(@number_of_records)
    end
  end

  context "with local authentication" do
    include_context "with local authentication"
    context "duplicate" do
      before(:each) do
        instance = Fabricate(factory)
        post_body = body_from_instance(instance, extra_params)
        @number_of_records = model_class.count
        post :create, post_body
      end
      it "responds with 409" do
        expect(response).to have_http_status(409)
      end
      it "does not create the record" do
        expect(model_class.count).to eql(@number_of_records)
      end
      it "renders nothing" do
        expect(response).to render_template(nil)
      end
    end

    context "with valid post body" do
      before(:each) do
        instance = Fabricate(factory, created_at: Time.now, updated_at: Time.now)
        @post_body = body_from_instance(instance, extra_params)
        model_class.delete(instance.id)
        @number_of_records = model_class.count
        post :create, @post_body
      end

      it "responds with 201" do
        expect(response).to have_http_status(201)
      end
      it "creates the record" do
        expect(model_class.public_send(:"find_by_#{key}", @post_body[key])).to be_valid
      end
      it "assigns the correct object to @#{factory.to_s}" do
        expect(assigns(factory)).to be_a model_class
        expect(assigns(factory).id).to eql(model_class.order("created_at").last.id)
      end
      it "renders json" do
        expect(response.content_type).to eql("application/json")
      end
      it "renders the create template" do
        expect(response).to render_template(:create)
      end
    end

    context "with invalid post body" do
      before(:each) do
        @number_of_records = model_class.count
        post :create, {}
      end
      it "responds with 400" do
        expect(response).to have_http_status(400)
      end
      it "does not create the record" do
        expect(model_class.count).to eql(@number_of_records)
      end
      it "assigns the correct object to @#{factory.to_s}" do
        expect(assigns(factory)).to be_a model_class
        expect(assigns(factory).errors.size).to be > 0
      end
      it "renders json" do
        expect(response.content_type).to eql("application/json")
      end
      it "renders the errors template" do
        expect(response).to render_template(:errors)
      end
    end
  end
end
