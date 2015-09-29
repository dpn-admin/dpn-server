# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

shared_examples "a paged endpoint" do |verb, action, params|
  raise ArgumentError, "Missing required parameters" unless verb && action && params
  page_size = 2
  before(:each) do
    params.delete(:page)
    params.delete(:page_size)
    Fabricate.times(3, factory)
  end

  context "with valid paging params" do
    before(:each) { self.send(verb, action, params.merge({page: 1, page_size: page_size})) }

    it "responds with 200" do
      expect(response).to have_http_status(200)
    end

    it "assigns the objects to @#{factory.to_s.pluralize}" do
      assignee = assigns(:"#{factory.to_s.pluralize}")
      expect(assignee).to respond_to(:size)
      expect(assignee.size).to eql(page_size)
    end

    it "renders json" do
      expect(response.content_type).to eql("application/json")
    end
  end

  context "without paging params" do
    before(:each) { self.send(verb, action, params) }

    it "responds with 302" do
      expect(response).to have_http_status(302)
    end

    it "redirects with page and page_size" do
      expect(response).to redirect_to action: :index,
                                      page: assigns(:page),
                                      page_size: assigns(:page_size)
    end
  end

  context "with page = -1" do
    before(:each) { self.send(verb, action, params.merge({page: -1, page_size: page_size})) }

    it "responds with 400" do
      expect(response).to have_http_status(400)
    end
  end

  big_page_size = Rails.configuration.max_per_page + 100
  context "with page_size = #{big_page_size}" do
    before(:each) { self.send(verb, action, params.merge({page: 1, page_size: big_page_size})) }

    it "responds with 302" do
      expect(response).to have_http_status(302)
    end

    it "redirects with page_size set to max" do
      expect(response).to redirect_to action: :index,
                                      page: assigns(:page),
                                      page_size: Rails.configuration.max_per_page
    end
  end

end