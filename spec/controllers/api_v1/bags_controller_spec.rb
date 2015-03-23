require 'rails_helper'

describe ApiV1::BagsController do
  before(:each) do
    @node = Fabricate(:node)
    @request.headers["Authorization"] = "Token token=#{@node.private_auth_token}"
  end

  describe "GET #index" do
    it "responds with 401 without authorization" do
      @request.headers["Authorization"] = nil
      get :index
      expect(response).to have_http_status(401)
    end

    it "responds with 200 (rails auth)" do
      get :index
      expect(response).to have_http_status(200)
    end

    it "responds with 200 (django auth)" do
      @request.headers["Authorization"] = "Token #{@node.private_auth_token}"
      get :index
      expect(response).to have_http_status(200)
    end

    it "has a json body" do
      get :index
      expect {
        ActiveSupport::JSON.decode(@response.body)
      }.to_not raise_error
    end

  end

  describe "GET #show" do
    before(:each) do
      @bag = Fabricate(:data_bag)
    end

    it "responds with 401 without authorization" do
      @request.headers["Authorization"] = nil
      get :show, {:uuid => @bag.uuid }
      expect(@response).to have_http_status(401)
    end

    it "responds with 200" do
      get :show, {:uuid => @bag.uuid }
      expect(@response).to have_http_status(200)
    end

    it "has a json body" do
      get :show, {:uuid => @bag.uuid }
      expect {
        ActiveSupport::JSON.decode(@response.body)
      }.to_not raise_error
    end
  end




end









