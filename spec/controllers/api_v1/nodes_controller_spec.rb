require 'rails_helper'

describe ApiV1::NodesController do

  describe "GET #index" do
    before(:each) do
      @auth_node = Fabricate(:node)
      Fabricate(:node)
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
        @request.headers["Authorization"] = "Token token=#{@auth_node.auth_credential}"
      end

      context "with paging parameters" do
        before(:each) do
          @params = {page: 1, page_size: 25}
        end
        it "also accepts django auth with 200" do
          @request.headers["Authorization"] = "Token #{@auth_node.auth_credential}"
          get :index, @params
          expect(response).to have_http_status(200)
        end
        it "responds with 200" do
          get :index, @params
          expect(response).to have_http_status(200)
        end
        it "assigns the nodes to @nodes" do
          get :index, @params
          expect(assigns(:nodes)).to_not be_nil
        end
        it "renders json" do
          get :index, @params
          expect(response.content_type).to eql("application/json")
        end
      end

      context "without paging parameters" do
        it "responds with 302" do
          get :index
          expect(response).to have_http_status(302)
        end
        it "redirects with page and page_size" do
          get :index
          expect(response).to redirect_to action: :index,
                                          page: assigns(:page),
                                          page_size: assigns(:page_size)
        end
      end

      context "with bad paging parameters" do

        context "(page = -1)" do
          it "responds with 400" do
            get :index, {page: -1, page_size: 25}
            expect(response).to have_http_status(400)
          end
        end

        context "(page_size = -1)" do
          it "responds with 400" do
            get :index, {page: 1, page_size: -1}
            expect(response).to have_http_status(400)
          end
        end

        context "page_size = 9999" do
          it "responds with 302" do
            get :index, {page: 1, page_size: 9999}
            expect(response).to have_http_status(302)
          end
          it "redirects with page_size set to max" do
            get :index, {page: 1, page_size: 9999}
            expect(response).to redirect_to action: :index,
                                            page: assigns(:page),
                                            page_size: Rails.configuration.max_per_page
          end
        end
      end
    end

  end

  describe "GET #show" do
    before(:each) do
      @auth_node = Fabricate(:node)
      @node = Fabricate(:node)
    end

    context "without authorization" do
      it "responds with 401" do
        get :show, namespace: @node.namespace
        expect(response).to have_http_status(401)
      end

      it "does not display data" do
        get :show, namespace: @node.namespace
        expect(response).to render_template(nil)
      end

    end

    context "with authorization" do
      before(:each) do
        @request.headers["Authorization"] = "Token token=#{@auth_node.auth_credential}"
      end

      context "without pre-existing record" do
        it "responds with 404" do
          get :show, namespace: "nonexistent"
          expect(response).to have_http_status(404)
        end

        it "renders nothing" do
          get :show, namespace: "nonexistent"
          expect(response).to render_template(nil)
        end

      end

      context "with pre-existing record" do
        it "responds with 200" do
          get :show, namespace: @node.namespace
          expect(response).to have_http_status(200)
        end

        it "assigns the correct node to @node" do
          get :show, namespace: @node.namespace
          expect(assigns(:node)).to_not be_nil
          expect(assigns(:node).to_hash[:namespace]).to eql(@node.namespace)
        end

        it "renders json" do
          get :show, namespace: @node.namespace
          expect(response.content_type).to eql("application/json")
        end

      end

    end
  end

  describe "POST #create" do
    before(:each) do
      @request.headers["Content-Type"] = "application/json"
      node = Fabricate.build(:node)
      other_nodes = Fabricate.times(4, :node)
      @post_body = {
          :name => node.name,
          :namespace => node.namespace,
          :api_root => node.api_root,
          :ssh_pubkey => node.ssh_pubkey,
          :replicate_from => other_nodes.collect { |n| n.namespace },
          :replicate_to => other_nodes.collect { |n| n.namespace },
          :restore_from => other_nodes.collect { |n| n.namespace },
          :restore_to => other_nodes.collect { |n| n.namespace },
          :protocols => Fabricate.times(2, :protocol).collect { |p| p.name },
          :fixity_algorithms => Fabricate.times(3, :fixity_alg).collect { |f| f.name },
          :created_at => "2015-02-25T16:24:02Z",
          :updated_at => "2015-02-25T16:24:02Z",
          :storage => {
              :region => Fabricate(:storage_region).name,
              :type => Fabricate(:storage_type).name
          },
          :private_auth_token => node.private_auth_token
      }
    end

    context "without authorization" do
      it "responds with 401" do
        post :create, @post_body
        expect(response).to have_http_status(401)
      end

      it "does not create the record" do
        post :create, @post_body
        expect(Node.find_by_namespace(@post_body[:namespace])).to be_nil
      end

    end

    context "with authorization" do
      context "as non-local node" do
        before(:each) do
          @auth_node = Fabricate(:node)
          @request.headers["Authorization"] = "Token token=#{@auth_node.auth_credential}"
        end

        it "responds with 403" do
          post :create, @post_body
          expect(response).to have_http_status(403)
        end

        it "does not create the record" do
          post :create, @post_body
          expect(Node.find_by_namespace(@post_body[:namespace])).to be_nil
        end

      end

      context "as local node" do
        before(:each) do
          @auth_node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
          @request.headers["Authorization"] = "Token token=#{@auth_node.auth_credential}"
        end

        context "with valid attributes" do
          it "responds with 201" do
            post :create, @post_body
            expect(response).to have_http_status(201)
          end

          it "saves the new object to the database" do
            post :create, @post_body
            expect(Node.find_by_namespace(@post_body[:namespace])).to be_valid
          end

          context "duplicate" do
            it "responds with 409" do
              existing_node = Fabricate(:node)
              @post_body[:namespace] = existing_node.namespace
              post :create, @post_body
              expect(response).to have_http_status(409)
            end

          end

        end

        context "without valid attributes" do
          before(:each) do
            @post_body[:storage] = "invalidstorage"
          end

          it "does not create the record" do
            post :create, @post_body
            expect(Node.find_by_namespace(@post_body[:namespace])).to be_nil
          end

          it "responds with 400" do
            post :create, @post_body
            expect(response).to have_http_status(400)
          end

        end

      end
    end
  end

  describe "PUT #update" do
    before(:each) do
      @request.headers["Content-Type"] = "application/json"
      @existing_node = Fabricate(:node)
      other_nodes = Fabricate.times(4, :node)
      @post_body = {
          :name => "some_new_name_for_this_node",
          :namespace => @existing_node.namespace,
          :api_root => @existing_node.api_root,
          :ssh_pubkey => @existing_node.ssh_pubkey,
          :replicate_from => other_nodes.collect { |n| n.namespace },
          :replicate_to => other_nodes.collect { |n| n.namespace },
          :restore_from => other_nodes.collect { |n| n.namespace },
          :restore_to => other_nodes.collect { |n| n.namespace },
          :protocols => Fabricate.times(2, :protocol).collect { |p| p.name },
          :fixity_algorithms => Fabricate.times(3, :fixity_alg).collect { |f| f.name },
          :created_at => @existing_node.created_at.to_formatted_s(:dpn),
          :updated_at => DateTime.now.utc.strftime(Time::DATE_FORMATS[:dpn]),
          :storage => {
              :region => @existing_node.storage_region.name,
              :type => @existing_node.storage_type.name
          }
      }
    end

    context "without authorization" do
      it "responds with 401" do
        put :update, @post_body
        expect(response).to have_http_status(401)
      end
      it "does not update the record" do
        put :update, @post_body
        expect(Node.find_by_namespace(@existing_node[:namespace])).to eql(@existing_node)
      end
    end

    context "with authorization" do
      context "as non-local node" do
        before(:each) do
          @auth_node = Fabricate(:node)
          @request.headers["Authorization"] = "Token token=#{@auth_node.auth_credential}"
        end

        it "responds with 403" do
          put :update, @post_body
          expect(response).to have_http_status(403)
        end
        it "does not update the record" do
          put :update, @post_body
          expect(Node.find_by_namespace(@existing_node[:namespace])).to eql(@existing_node)
        end
      end

      context "as local node" do
        before(:each) do
          @auth_node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
          @request.headers["Authorization"] = "Token token=#{@auth_node.auth_credential}"
        end

        context "record does not exist" do
          before(:each) do
            @post_body[:namespace] = "sfdafasdfa"
          end

          it "responds with 404" do
            put :update, @post_body
            expect(response).to have_http_status(404)
          end
          it "does not update/create the record" do
            put :update, @post_body
            expect(Node.find_by_namespace(@existing_node[:namespace])).to eql(@existing_node)
          end
        end

        context "with invalid attributes" do
          before(:each) do
            @post_body[:storage] = "invalidstorage"
          end
          it "responds with 400" do
            put :update, @post_body
            expect(response).to have_http_status(400)
          end
          it "does not update the record" do
            put :update, @post_body
            expect(Node.find_by_namespace(@existing_node[:namespace])).to eql(@existing_node)
          end
        end

        context "with valid attributes" do
          before(:each) { @post_body[:name] = "adfasfdasdfsagsdgagadgd" }
          context "with old timestamp" do
            before(:each) do
              @post_body[:created_at] = "2010-02-25T16:24:02Z"
              @post_body[:updated_at] = "2010-02-25T16:24:02Z"
            end
            it "responds with 400" do
              put :update, @post_body
              expect(response).to have_http_status(400)
            end
            it "does not update the record" do
              put :update, @post_body
              expect(Node.find_by_namespace(@existing_node[:namespace])).to eql(@existing_node)
            end
          end
          it "responds wtih 200" do
            put :update, @post_body
            expect(response).to have_http_status(200)
          end
          it "saves the change to the database" do
            put :update, @post_body
            node = Node.find_by_namespace(@existing_node[:namespace])
            expect(node.name).to eql(@post_body[:name])
            expected_nodes = @existing_node.restore_to_nodes.collect { |n| n.namespace }
            expect(node.restore_to_nodes.collect {|n| n.namespace}).to match_array(expected_nodes)
          end
        end

      end
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @node = Fabricate(:node)
    end
    context "without authorization" do
      subject { delete :destroy, namespace: @node.namespace }
      it "responds with 401" do
        subject()
        expect(response).to have_http_status(401)
      end
      it "does not delete the record" do
        subject()
        expect(Node.find_by_namespace(@node.namespace)).to be_valid
      end
    end
    context "with authorization" do
      subject { delete :destroy, namespace: @node.namespace }
      context "as non-local node" do
        before(:each) do
          @auth_node = Fabricate(:node)
          @request.headers["Authorization"] = "Token token=#{@auth_node.auth_credential}"
        end
        it "responds with 403" do
          subject()
          expect(response).to have_http_status(403)
        end
        it "does not delete the record" do
          subject()
          expect(Node.find_by_namespace(@node.namespace)).to be_valid
        end
      end
      context "as local node" do
        before(:each) do
          @auth_node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
          @request.headers["Authorization"] = "Token token=#{@auth_node.auth_credential}"
        end
        context "without pre-existing record" do
          subject { delete :destroy, namespace: "does_not_exist" }
          it "responds with 404" do
            subject()
            expect(response).to have_http_status(404)
          end
          it "renders nothing" do
            subject()
            expect(response).to render_template(nil)
          end
        end
        context "with pre-existing record" do
          subject { delete :destroy, namespace: @node.namespace }
          it "responds with 204" do
            subject()
            expect(response).to have_http_status(204)
          end
          it "deletes the bag" do
            subject()
            expect(Node.find_by_namespace(@node.namespace)).to be_nil
          end
        end
      end
    end
  end
end

