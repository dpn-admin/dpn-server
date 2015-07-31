require 'rails_helper'

shared_examples "an update" do |expected_field, expected_value|
  before(:each) do
    subject
  end
  it "saves the change to the database" do
    expect(@existing.reload.send(expected_field)).to eql(expected_value)
  end
  it "responds with 200" do
    expect(response).to have_http_status(200)
  end
end

describe ApiV1::BagMgr::RequestsController, type: :controller do
  before(:each) do
    @request.headers["Content-Type"] = "application/json"
    @bag_mgr_request = Fabricate(:bag_manager_request)
  end

  context "without authorization" do
    it "responds with 401" do
      get :index
      expect(response).to have_http_status(401)
    end
    it "does not display data" do
      get :index
      expect(response).to render_template(nil)
    end
  end

  context "with authorization" do
    context "as local node" do
      before(:each) do
        @node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
        @request.headers["Authorization"] = "Token token=#{@node.auth_credential}"
      end

      describe "GET #index" do
        it "returns http success" do
          get :index
          expect(response).to have_http_status(:success)
        end
        it "assigns the requests to @requests" do
          get :index
          expect(assigns(:requests)).to_not be_nil
          expect(assigns(:requests).size).to be >= 1
        end
      end

      describe "GET #show" do
        context "without pre-existing record" do
          it "responds with 404" do
            get :show, id: "fake"
            expect(response).to have_http_status(404)
          end
          it "renders nothing" do
            get :show, id: "fake"
            expect(response).to render_template(nil)
          end
        end
        context "with pre-existing record" do
          it "responds with 200" do
            get :show, id: @bag_mgr_request.id
            expect(response).to have_http_status(200)
          end
          it "assigns the correct request to @request" do
            get :show, id: @bag_mgr_request.id
            expect(assigns(:request)).to_not be_nil
            expect(assigns(:request).source_location).to eql(@bag_mgr_request.source_location)
          end
          it "renders json" do
            get :show, id: @bag_mgr_request.id
            expect(response.content_type).to eql("application/json")
          end
        end
      end

      describe "POST #create" do
        before(:each) do
          @post_body = { source_location: Faker::Internet.url }
        end

        it "responds with 201" do
          post :create, @post_body
          expect(response).to have_http_status(201)
        end

        it "saves the new object to the database" do
          post :create, @post_body
          expect(@bag_mgr_request.reload).to be_valid
        end

        it "spawns a BagRetrievalJob" do
          expect {
            post :create, @post_body
          }.to enqueue_a(BagRetrievalJob)
        end
      end

      describe "PUT #downloaded" do
        before(:each) do
          @existing = Fabricate(:bag_manager_request, status: :requested)
        end
        subject { put :downloaded, id: @existing.id }
        it_behaves_like "an update", :status, :downloaded.to_s
      end

      describe "PUT #unpacked" do
        before(:each) do
          @existing = Fabricate(:bag_manager_request, status: :downloaded)
        end
        subject { put :unpacked, id: @existing.id}
        it_behaves_like "an update", :status, :unpacked.to_s
      end

      describe "PUT #fixity" do
        before(:each) do
          @existing = Fabricate(:bag_manager_request, status: :unpacked)
        end
        subject { put :fixity, id: @existing.id, fixity: "somefixity" }
        it_behaves_like "an update", :fixity, "somefixity"
      end

      describe "PUT #validity" do
        before(:each) do
          @existing = Fabricate(:bag_manager_request, status: :unpacked)
        end
        subject { put :validity, id: @existing.id, validity: true}
        it_behaves_like "an update", :validity, true
      end

      describe "PUT #preserved" do
        before(:each) do
          @existing = Fabricate(:bag_manager_request, status: :unpacked,
                                validity: true, fixity: "somefixity")
        end
        subject { put :preserved, id: @existing.id}
        it_behaves_like "an update", :status, :preserved.to_s
      end

      describe "PUT #cancel" do
        before(:each) do
          @existing = Fabricate(:bag_manager_request)
        end
        subject { put :cancel, id: @existing.id}
        it_behaves_like "an update", :cancelled, true
      end

      describe "DELETE #destroy" do
        before(:each) do
          @existing = Fabricate(:bag_manager_request)
        end
        it "destroys the record" do
          delete :destroy, id: @existing.id
          expect(BagManagerRequest.exists?(@existing.id)).to be false
        end
        it "has status code 204" do
          delete :destroy, id: @existing.id
          expect(response).to have_http_status(204)
        end
        it "returns 404 if the record doesn't exist" do
          delete :destroy, id: 37272
          expect(response).to have_http_status(404)
        end
      end

    end

    context "as another node" do
      before(:each) do
        token = Faker::Code.isbn
        @node = Fabricate(:node, private_auth_token: token)
        @request.headers["Authorization"] = "Token token=#{token}"
      end

      describe "GET #index" do
        it "responds with 403" do
          get :index
          expect(response).to have_http_status(403)
        end
      end
      describe "GET #show" do
        it "responds with 403" do
          get :show, id: @bag_mgr_request.id
          expect(response).to have_http_status(403)
        end
      end
      describe "POST #create" do
        it "responds with 403" do
          post :create, source_location: @bag_mgr_request.source_location
          expect(response).to have_http_status(403)
        end
      end
      describe "PUT #downloaded" do
        it "responds with 403" do
          put :downloaded, id: @bag_mgr_request.id
          expect(response).to have_http_status(403)
        end
      end
      describe "PUT #unpacked" do
        it "responds with 403" do
          put :unpacked, id: @bag_mgr_request.id
          expect(response).to have_http_status(403)
        end
      end
      describe "PUT #fixity" do
        it "responds with 403" do
          put :fixity, id: @bag_mgr_request.id, fixity: "somefixity"
          expect(response).to have_http_status(403)
        end
      end
      describe "PUT #validity" do
        it "responds with 403" do
          put :validity, id: @bag_mgr_request.id, validity: true
          expect(response).to have_http_status(403)
        end
      end
      describe "PUT #preserved" do
        it "responds with 403" do
          put :preserved, id: @bag_mgr_request.id
          expect(response).to have_http_status(403)
        end
      end
      describe "PUT #cancel" do
        it "responds with 403" do
          put :cancel, id: @bag_mgr_request.id
          expect(response).to have_http_status(403)
        end
      end

    end

  end


end
