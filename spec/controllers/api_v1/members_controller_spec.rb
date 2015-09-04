require 'rails_helper'

describe ApiV1::MembersController do
  describe "GET #index" do
    before(:each) do
      @member = Fabricate(:member)
      @node = Fabricate(:node)
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
      before(:each) do
        @request.headers["Authorization"] = "Token token=#{@node.auth_credential}"
      end

      context "with paging parameters" do
        before(:each) do
          @params = {page: 1, page_size: 25}
        end
        it "responds with 200" do
          get :index, @params
          expect(response).to have_http_status(200)
        end
        it "renders json" do
          get :index, @params
          expect(response.content_type).to eql("application/json")
        end
      end
    end
  end

  describe "GET #show" do
    before(:each) do
      @node = Fabricate(:node)
      @member = Fabricate(:member)
    end

    context "with authorization" do
      before(:each) do
        @request.headers["Authorization"] = "Token token=#{@node.auth_credential}"
      end

      context "without existing member" do
        it "responds with 404" do
          get :show, uuid: SecureRandom.uuid
          expect(response).to have_http_status(404)
        end
        it "renders nothing" do
          get :show, uuid: SecureRandom.uuid
          expect(response).to render_template(nil)
        end
      end

      context "with existing member" do
        it "responds with 200" do
          get :show, uuid: @member.uuid
          expect(response).to have_http_status(200)
        end
        it "renders json" do
          get :show, uuid: @member.uuid
          expect(response.content_type).to eql("application/json")
        end
      end
    end
  end

  describe "POST #create" do
    before(:each) do
      @request.headers["Content-Type"] = "application/json"
      uuid = SecureRandom.uuid
      name = Faker::Company.name
      email = Faker::Internet.email
      @post_body = {
        :uuid => uuid,
        :name => name,
        :email => email
      }
    end

    context "with authorization" do
      context "as local node" do
        before(:each) do
          @node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
          @request.headers["Authorization"] = "Token token=#{@node.auth_credential}"
        end

        context "with valid attributes" do
          it "responds with 201" do
            post :create, @post_body
            expect(response).to have_http_status(201)
          end

          it "saves member to database" do
            post :create, @post_body
            expect(Member.find_by_uuid(@post_body[:uuid])).to be_valid
          end

          context "duplicate" do
            it "responds with 409" do
              existing_member = Fabricate(:member)
              @post_body[:uuid] = existing_member.uuid
              post :create, @post_body
              expect(response).to have_http_status(409)
            end
          end
        end

      end
    end
  end
  
  describe "PUT #update" do
    before(:each) do
      @request.headers["Content-Type"] = "application/json"
      @existing_member = Fabricate(:member)
      @post_body = {
        :uuid => @existing_member.uuid,
        :name => @existing_member.name,
        :email => Faker::Internet.email
      }
    end
    context "with authorization" do
      context "as local node" do
        before(:each) do
          @node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
          @request.headers["Authorization"] = "Token token=#{@node.auth_credential}"
        end
        context "with valid attributes" do 
          it "responds with 200" do
            put :update, @post_body
            expect(response).to have_http_status(200)
          end
          it "saves the changes to the db" do
            put :update, @post_body
            expect(Member.find_by_uuid(@existing_member.uuid).email).to eql(@post_body[:email])
          end

          context "with new name" do
            before(:each) do
              @post_body[:name] = Faker::Company.name
              @post_body[:email] = @existing_member.email
            end
            it "responds with 400" do
              put :update, @post_body
              expect(response).to have_http_status(400)
            end
            it "does not update the record" do
              put :update, @post_body
              expect(Member.find_by_uuid(@existing_member.uuid).name).to eql(@existing_member.name)
            end
          end 
        end

        context "member does not exist" do
          before(:each) do
            @post_body[:uuid] = SecureRandom.uuid
          end
          it "responds with 404" do
            put :update, @post_body
            expect(response).to have_http_status(404)
          end
          it "does not update the record" do
            put :update, @post_body
            expect(Bag.find_by_uuid(@post_body[:uuid])).to be_nil
          end

        end
      end
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @member = Fabricate(:member)
      context "with authorization" do
        context "as local node" do
          before(:each) do  
            @node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
            @request.headers["Authorization"] = "Token token=#{@node.auth_credential}"
          end
          context "with existing member" do
            subject {delete :destroy, uuid: @member.uuid}
            it "responds with 204" do
              subject()
              expect(response).to have_http_status(204)
            end
            it "deletes the member" do
              subject()
              expect(Member.find_by_uuid(@member[:uuid])).to be_nil
            end
          end
          context "without existing member" do
            subject {delete :destroy, uuid: @member.uuid}
            it "responds with 404" do
              subject()
              expect(response).to have_http_status(404)
            end
            it "renders nothing" do
              subject()
              expect(response).to render_template(nil)
            end
          end
        end
      end
    end
  end
end
