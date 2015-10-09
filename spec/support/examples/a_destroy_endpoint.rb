# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

shared_examples "a destroy endpoint" do |key|
  context "without authentication" do
    before(:each) do
      @instance = Fabricate(factory)
      delete :destroy, key => @instance.public_send(key)
    end
    it_behaves_like "an unauthenticated request"
    it "does not delete data" do
      expect(model_class.exists?(@instance.id)).to be true
    end
  end
  context "with authentication" do
    include_context "with authentication"
    before(:each) do
      @instance = Fabricate(factory)
      delete :destroy, key => @instance.send(key)
    end
    it_behaves_like "an unauthorized request"
    it "does not delete data" do
      expect(model_class.exists?(@instance.id)).to be true
    end
  end
  context "with local authentication" do
    include_context "with local authentication"
    before(:each) { @instance = Fabricate(factory) }

    context "record doesn't exist" do
      before(:each) { delete :destroy, key => SecureRandom.uuid }
      it "responds with 404" do
        expect(response).to have_http_status(404)
      end
      it "renders nothing" do
        expect(response).to render_template(nil)
      end
      it "does not delete data" do
        expect(model_class.exists?(@instance.id)).to be true
      end
    end

    context "record exists" do
      before(:each) { delete :destroy, key => @instance.public_send(key) }
      it "responds with 200" do
        expect(response).to have_http_status(204)
      end
      it "renders nothing" do
        expect(response).to render_template(nil)
      end
      it "deletes the #{factory.to_s}" do
        expect(model_class.exists?(@instance.id)).to be false
      end
    end
  end
end