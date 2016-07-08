# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

shared_examples "an authorized update" do |key, options, legal_update, illegal_update|
  raise ArgumentError, "Missing required parameters" unless key && legal_update && illegal_update
  unless options
    options = proc {{}}
  end
  
  old_updated_at = 1.year.ago.utc
  params_updated_at = 1.day.ago.utc

  before(:each) do
    @request.headers["Content-Type"] = "application/json"
    model_options = options.call
    model_options[:updated_at] = old_updated_at
    @existing_record = Fabricate(factory, model_options)
    @put_body = adapter.from_model(@existing_record).to_public_hash
    @put_body[:updated_at] = params_updated_at.to_formatted_s(:dpn)
  end
  
  it "fabricates the record with the correct timestamp" do
    expect(@existing_record.reload.updated_at.to_s).to eql(old_updated_at.to_s)
  end

  context "record doesn't exist" do
    before(:each) do
      @put_body[key] = SecureRandom.uuid
      put :update, legal_update.call(@put_body)
    end
    it "responds with 404" do
      expect(response).to have_http_status(404)
    end
    it "renders nothing" do
      expect(response).to render_template(nil)
    end
    it "does not update the record" do
      expect(@existing_record.reload.updated_at.to_s).to eql(old_updated_at.to_s)
    end
  end

  context "with valid put body" do
    before(:each) { put :update, legal_update.call(@put_body) }
    it "responds with 200" do
      expect(response).to have_http_status(200)
    end
    it "updates the record" do
      expect(@existing_record.reload.updated_at).to be > old_updated_at + 1.second
    end
    it "assigns the correct object to @#{factory}" do
      expect(assigns(factory)).to be_an @existing_record.class
      expect(assigns(factory).id).to eql(@existing_record.id)
    end
    it "renders json" do
      expect(response.content_type).to eql("application/json")
    end
    it "renders the create template" do
      expect(response).to render_template(:update)
    end
  end

  context "with invalid put body" do
    before(:each) { put :update, illegal_update.call(@put_body) }
    it "responds with 400" do
      expect(response).to have_http_status(400)
    end
    it "does not update the record" do
      expect(@existing_record.reload.updated_at.to_s).to eql(old_updated_at.to_s)
    end
    it "assigns the correct object to @#{factory}" do
      expect(assigns(factory)).to be_an model_class
      expect(assigns(factory).id).to eql(@existing_record.id)
    end
    it "renders json" do
      expect(response.content_type).to eql("application/json")
    end
    it "renders the errors template" do
      expect(response).to render_template(:errors)
    end
  end

  context "with no changes other than timestamps" do
    before(:each) do
      @put_body[:updated_at] = 1.day.from_now.utc.to_formatted_s(:dpn)
      put :update, @put_body
    end
    it "responds with 200" do
      expect(response).to have_http_status(200)
    end
    it "does not update the record" do
      expect(@existing_record.reload.updated_at.change(usec: 0)).to eql(old_updated_at.change(usec: 0))
    end
    it "assigns the correct object to @#{factory}" do
      expect(assigns(factory)).to be_an model_class
      expect(assigns(factory).id).to eql(@existing_record.id)
    end
    it "renders json" do
      expect(response.content_type).to eql("application/json")
    end
    it "renders the update template" do
      expect(response).to render_template(:update)
    end
  end

  context "with old timestamps" do
    before(:each) do
      @put_body[:created_at] = 3.years.ago.utc.to_formatted_s(:dpn)
      @put_body[:updated_at] = 2.years.ago.utc.to_formatted_s(:dpn)
      put :update, legal_update.call(@put_body)
    end
    it "responds with 200" do
      expect(response).to have_http_status(200)
    end
    it "updates the record" do
      expect(@existing_record.reload.updated_at.change(usec: 0)).to be > old_updated_at.change(usec: 0)
    end
    it "assigns the correct object to @#{factory}" do
      expect(assigns(factory)).to be_an @existing_record.class
      expect(assigns(factory).id).to eql(@existing_record.id)
    end
    it "renders json" do
      expect(response.content_type).to eql("application/json")
    end
    it "renders the create template" do
      expect(response).to render_template(:update)
    end
  end
end