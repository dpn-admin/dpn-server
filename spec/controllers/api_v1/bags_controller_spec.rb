require 'rails_helper'

describe ApiV1::BagsController do

  describe "GET #index" do
    before(:each) do
      @node = Fabricate(:node)
      @bag = Fabricate(:data_bag)
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
        @request.headers["Authorization"] = "Token token=#{@node.private_auth_token}"
      end
      it "also accepts django auth with 200" do
        @request.headers["Authorization"] = "Token #{@node.private_auth_token}"
        get :index
        expect(response).to have_http_status(200)
      end
      it "responds with 200" do
        get :index
        expect(response).to have_http_status(200)
      end
      it "assigns the bags to @bags" do
        get :index
        expect(assigns(:bags)).to_not be_nil
      end
      it "renders json" do
        get :index
        expect(response.content_type).to eql("application/json")
      end
    end
  end

  describe "GET #show" do
    before(:each) do
      @node = Fabricate(:node)
      @bag = Fabricate(:data_bag)
    end
    context "without authorization" do
      it "responds with 401" do
        get :show, uuid: @bag.uuid
        expect(response).to have_http_status(401)
      end
      it "does not display data" do
        get :show, uuid: @bag.uuid
        expect(response).to render_template(nil)
      end
    end
    context "with authorization" do
      before(:each) do
        @request.headers["Authorization"] = "Token token=#{@node.private_auth_token}"
      end
      context "without pre-existing record" do
        it "responds with 404" do
          get :show, uuid: SecureRandom.uuid
          expect(response).to have_http_status(404)
        end
        it "renders nothing" do
          get :show, uuid: SecureRandom.uuid
          expect(response).to render_template(nil)
        end
      end
      context "with pre-existing record" do
        it "responds with 200" do
          get :show, uuid: @bag.uuid
          expect(response).to have_http_status(200)
        end
        it "assigns the correct bag to @bag" do
          get :show, uuid: @bag.uuid
          expect(assigns(:bag)).to_not be_nil
          expect(assigns(:bag).to_hash[:uuid]).to eql(@bag.uuid)
        end
        it "renders json" do
          get :show, uuid: @bag.uuid
          expect(response.content_type).to eql("application/json")
        end
      end
    end
  end

  describe "POST #create" do
    before(:each) do
      @request.headers["Content-Type"] = "application/json"
      ingest_node = Fabricate(:node)
      admin_node = ingest_node
      interpretive  = Fabricate.times(3, :interpretive_bag)
      rights = Fabricate.times(2, :rights_bag)
      replicating_nodes = Fabricate.times(3, :node)
      fixity_alg = Fabricate(:fixity_alg)
      uuid = SecureRandom.uuid
      @post_body = {
          :uuid => uuid,
          :ingest_node => ingest_node.namespace,
          :interpretive => interpretive.collect { |bag| bag.uuid },
          :rights => rights.collect { |bag| bag.uuid },
          :replicating_nodes => replicating_nodes.collect { |node| node.namespace },
          :admin_node => admin_node.namespace,
          :fixities => {
            fixity_alg.name => "somefixityvalue"
          },
          :local_id => "some_local_id",
          :size => 1298371935,
          :first_version_uuid => uuid,
          :version => 1,
          :bag_type => "D",
          :created_at => "2015-02-25T16:24:02Z",
          :updated_at => "2015-02-25T16:24:02Z"
      }
    end

    context "without authorization" do
      it "responds with 401" do
        post :create, @post_body
        expect(response).to have_http_status(401)
      end
      it "does not create the record" do
        post :create, @post_body
        expect(Bag.find_by_uuid(@post_body[:uuid])).to be_nil
      end
    end
    context "with authorization" do
      context "as non-local node" do
        before(:each) do
          @node = Fabricate(:node)
          @request.headers["Authorization"] = "Token token=#{@node.private_auth_token}"
        end
        it "responds with 403" do
          post :create, @post_body
          expect(response).to have_http_status(403)
        end
        it "does not create the record" do
          post :create, @post_body
          expect(Bag.find_by_uuid(@post_body[:uuid])).to be_nil
        end
      end

      context "as local node" do
        before(:each) do
          @node = Fabricate(:node, namespace: Rails.configuration.local_namespace)
          @request.headers["Authorization"] = "Token token=#{@node.private_auth_token}"
        end
        context "with valid attributes" do
          it "responds with 201" do
            post :create, @post_body
            expect(response).to have_http_status(201)
          end
          it "saves the new object to the database" do
            post :create, @post_body
            expect(Bag.find_by_uuid(@post_body[:uuid])).to be_valid
          end
          context "duplicate" do
            it "responds with 409" do
              existing_bag = Fabricate(:bag)
              @post_body[:uuid] = existing_bag.uuid
              @post_body[:first_version_uuid] = existing_bag.uuid
              post :create, @post_body
              expect(response).to have_http_status(409)
            end
          end
        end
        context "without valid attributes" do
          before(:each) do
            @post_body[:size] = "unknown"
          end
          it "does not create the record" do
            post :create, @post_body
            expect(Bag.find_by_uuid(@post_body[:uuid])).to be_nil
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
      @existing_bag = Fabricate(:data_bag)
      @post_body = {
          :uuid => @existing_bag.uuid,
          :ingest_node => @existing_bag.ingest_node.namespace,
          :interpretive => @existing_bag.interpretive_bags.collect { |bag| bag.uuid },
          :rights => @existing_bag.rights_bags.collect { |bag| bag.uuid },
          :replicating_nodes => @existing_bag.replicating_nodes.collect { |node| node.namespace },
          :admin_node => @existing_bag.admin_node.namespace,
          :fixities => {},
          :local_id => "look_everyone_a_new_local_id",
          :size => @existing_bag.size,
          :first_version_uuid => @existing_bag.version_family.uuid,
          :version => @existing_bag.version,
          :bag_type => "D",
          :created_at => @existing_bag.created_at.to_formatted_s(:dpn),
          :updated_at => "2011-02-25T16:24:02Z"
      }

      @existing_bag.fixity_checks.each do |check|
        @post_body[:fixities][check.fixity_alg.name.to_sym] = check.value
      end
    end

    context "without authorization" do
      it "responds with 401" do
        put :update, @post_body
        expect(response).to have_http_status(401)
      end
      it "does not update the record" do
        put :update, @post_body
        expect(Bag.find_by_uuid(@post_body[:uuid])).to eql(@existing_bag)
      end
    end

    context "with authorization" do
      context "as non-local node" do
        before(:each) do
          @node = Fabricate(:node)
          @request.headers["Authorization"] = "Token token=#{@node.private_auth_token}"
        end
        it "responds with 403" do
          put :update, @post_body
          expect(response).to have_http_status(403)
        end
        it "does not update the record" do
          put :update, @post_body
          expect(Bag.find_by_uuid(@post_body[:uuid])).to eql(@existing_bag)
        end
      end
      context "as local node" do
        before(:each) do
          @node = Fabricate(:node, namespace: Rails.configuration.local_namespace)
          @request.headers["Authorization"] = "Token token=#{@node.private_auth_token}"
        end
        context "record does not exist" do
          before(:each) do
            @post_body[:uuid] = SecureRandom.uuid # Because of the way rails and rspec interact,
          end                                     # setting the param in the body is the same as
          it "responds with 404" do               # just routing differently.
            put :update, @post_body
            expect(response).to have_http_status(404)
          end
          it "does not update the record" do
            put :update, @post_body
            expect(Bag.find_by_uuid(@post_body[:uuid])).to be_nil
          end
        end
        context "with invalid attributes" do
          it "responds with 400" do
            @post_body[:bag_type] = "X"
            put :update, @post_body
            expect(response).to have_http_status(400)
          end
          it "does not update the record" do
            @post_body[:bag_type] = "X"
            put :update, @post_body
            expect(Bag.find_by_uuid(@post_body[:uuid])).to eql(@existing_bag)
          end
        end
        context "with valid attributes" do
          it "responds wtih 200" do
            put :update, @post_body
            expect(response).to have_http_status(200)
          end
          it "saves the change to the database" do
            put :update, @post_body
            expect(Bag.find_by_uuid(@existing_bag.uuid).local_id).to eql(@post_body[:local_id])
            expect(Bag.find_by_uuid(@existing_bag.uuid).replicating_nodes.collect { |node| node.namespace }).to match_array(@post_body[:replicating_nodes])
          end
        end
      end
    end
  end
end

