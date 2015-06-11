require 'rails_helper'

def build_post_body(repl, status)
  hash = {
      :replication_id => repl.replication_id,
      :from_node => repl.from_node.namespace,
      :to_node => repl.to_node.namespace,
      :uuid => repl.bag.uuid,
      :fixity_algorithm => repl.fixity_alg.name,
      :fixity_nonce => repl.fixity_nonce,
      :fixity_value => repl.fixity_value,
      :fixity_accept => repl.fixity_accept,
      :bag_valid => repl.bag_valid,
      :status => status.to_s,
      :protocol => repl.protocol.name,
      :link => repl.link,
      :created_at => repl.created_at.to_formatted_s(:dpn),
      :updated_at => DateTime.now.utc.strftime(Time::DATE_FORMATS[:dpn])
  }

  if [:received, :confirmed, :stored, :cancelled].include?(status)
    hash[:fixity_value] ||= "somefixityvalueasdfasfasfafasd"
    hash[:bag_valid] ||= [true,false].sample

    if status != :received
      hash[:fixity_accept] ||= [true,false].sample
    end
  end

  return hash
end


shared_examples "failure" do |id_field|
  it "responds with 400" do
    put :update, post_body
    expect(response).to have_http_status(400)
  end
  it "does not update the record" do
    put :update, post_body
    instance_from_db = existing_instance.class.public_send("find_by_#{id_field}", existing_instance.public_send(id_field))
    expect(instance_from_db).to eql(existing_instance)
  end
end


shared_examples "success" do |id_field, changed_fields|
  it "responds with 200" do
    put :update, post_body
    expect(response).to have_http_status(200)
  end
  it "updates the record" do
    put :update, post_body
    instance_from_db = existing_instance.class.public_send("find_by_#{id_field}", existing_instance.public_send(id_field))
    changed_fields.each do |changed_field|
      expect(instance_from_db.public_send(changed_field)).to_not eql(existing_instance.public_send(changed_field))
    end
  end
end


shared_examples "a statemachine" do |starting_status, allowed_statuses|
  context "starting_status==#{starting_status}" do
    before(:each) do
      status_hash = {
          replication_status: ReplicationStatus.find_by_name(starting_status)
      }
      @existing_instance = Fabricate("replication_transfer_#{starting_status}".to_sym, more_params)
    end

    all_statuses = [ :requested, :rejected, :received, :confirmed, :stored, :cancelled ]

    (all_statuses - allowed_statuses).each do |status| #disallowed statuses
      context "new_status==#{status}" do
        before(:each) do
          @post_body = build_post_body(@existing_instance, status)
        end
        it_behaves_like "failure", :replication_id do
          let(:post_body) { @post_body }
          let(:existing_instance) { @existing_instance }
        end
      end
    end

    allowed_statuses.each do |status|
      context "new_status==#{status}" do
        before(:each) do
          @post_body = build_post_body(@existing_instance, status)
        end
        it_behaves_like "success", :replication_id, [:replication_status] do
          let(:post_body) { @post_body }
          let(:existing_instance) { @existing_instance }
        end
      end
    end
  end
end


describe ApiV1::ReplicationTransfersController do
  before(:all) do
    [ :requested, :rejected, :received, :confirmed, :stored, :cancelled ].each do |status_name|
      Fabricate(:replication_status, name: status_name)
    end
  end

  after(:all) do
    ReplicationStatus.destroy_all
  end

  describe "GET #index" do
    before(:each) do
      @auth_node = Fabricate(:node)
      Fabricate.times(2, :replication_transfer)
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
        it "assigns the replication transfers to @replication_transfers" do
          get :index, @params
          expect(assigns(:replication_transfers)).to_not be_nil
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
      @repl = Fabricate(:replication_transfer)
    end

    context "without authorization" do
      it "responds with 401" do
        get :show, replication_id: @repl.replication_id
        expect(response).to have_http_status(401)
      end

      it "does not display data" do
        get :show, replication_id: @repl.replication_id
        expect(response).to render_template(nil)
      end

    end

    context "with authorization" do
      before(:each) do
        @request.headers["Authorization"] = "Token token=#{@auth_node.auth_credential}"
      end

      context "without pre-existing record" do
        it "responds with 404" do
          get :show, replication_id: "nonexistent"
          expect(response).to have_http_status(404)
        end

        it "renders nothing" do
          get :show, replication_id: "nonexistent"
          expect(response).to render_template(nil)
        end

      end

      context "with pre-existing record" do
        it "responds with 200" do
          get :show, replication_id: @repl.replication_id
          expect(response).to have_http_status(200)
        end

        it "assigns the correct record to @replication_transfer" do
          get :show, replication_id: @repl.replication_id
          expect(assigns(:replication_transfer)).to_not be_nil
          expect(assigns(:replication_transfer).to_hash[:uuid]).to eql(@repl.bag.uuid)
        end

        it "renders json" do
          get :show, replication_id: @repl.replication_id
          expect(response.content_type).to eql("application/json")
        end

      end

    end
  end

  describe "POST #create" do
    before(:each) do

    end
    context "without authorization" do
      it "responds with 401"
      it "does not create the record"
    end

    context "with authorization" do
      context "as non-local node" do
        it "responds with 403"
        it "does not create the record"
      end
      context "as local node" do
        context "with valid attributes" do
          it "responds with 201"
          it "saves the new object to the database"
          context "duplicate" do
            it "responds with 409"
          end
        end
        context "without valid attributes" do
          it "does not create the record"
          it "responds with 400"
        end

      end
    end
  end

  describe "PUT #update" do

    describe "state transition tests" do
      @all_statuses = [ :requested, :rejected, :received, :confirmed, :stored, :cancelled ]

      context "put comes from local_node" do
        before(:each) do
          @local_node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
          @auth_node = @local_node
          @request.headers["Authorization"] = "Token token=#{@auth_node.auth_credential}"
        end
        context "where local_node==from_node" do  # We requested it and we're updating
          test_context = Proc.new {
            let(:more_params) do
              { from_node: @local_node }
            end
          }
          it_behaves_like "a statemachine", :requested, [:cancelled] { test_context.call }
          it_behaves_like "a statemachine", :rejected, [] { test_context.call }
          it_behaves_like "a statemachine", :received, [:confirmed, :cancelled] { test_context.call }
          it_behaves_like "a statemachine", :confirmed, [:cancelled] { test_context.call }
          it_behaves_like "a statemachine", :stored, [] { test_context.call }
          it_behaves_like "a statemachine", :cancelled, [] { test_context.call }
        end

        context "where local_node==to_node" do  # We're the requestee and we're syncing
          test_context = Proc.new {
            let(:more_params) do
              { to_node: @local_node }
            end
          }
          it_behaves_like "a statemachine", :requested, [:cancelled, :rejected, :received, :confirmed] { test_context.call }
          it_behaves_like "a statemachine", :rejected, [] { test_context.call }
          it_behaves_like "a statemachine", :received, [:confirmed, :cancelled] { test_context.call }
          it_behaves_like "a statemachine", :confirmed, [:cancelled, :stored] { test_context.call }
          it_behaves_like "a statemachine", :stored, [] { test_context.call }
          it_behaves_like "a statemachine", :cancelled, [] { test_context.call }
        end

        context "where local_node is unimplicated" do  # We're uninvolved and we're syncing
          test_context = Proc.new do
            let(:more_params) { Hash.new }
          end
          it_behaves_like "a statemachine", :requested, [:cancelled, :rejected, :received, :confirmed, :stored] { test_context.call }
          it_behaves_like "a statemachine", :rejected, [] { test_context.call }
          it_behaves_like "a statemachine", :received, [:confirmed, :cancelled, :stored] { test_context.call }
          it_behaves_like "a statemachine", :confirmed, [:cancelled, :stored] { test_context.call }
          it_behaves_like "a statemachine", :stored, [] { test_context.call }
          it_behaves_like "a statemachine", :cancelled, [] { test_context.call }
        end
      end

      context "put comes from to_node" do
        before(:each) do
          token = Faker::Code.isbn
          @to_node = Fabricate(:node, private_auth_token: token)
          @auth_node = @to_node
          @local_node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
          @request.headers["Authorization"] = "Token token=#{token}"
        end
        context "where local_node==from_node" do
          test_context = Proc.new {
            let(:more_params) do
              { from_node: @local_node,
                to_node: @to_node
              }
            end
          }
          it_behaves_like "a statemachine", :requested, [:rejected, :received, :cancelled] { test_context.call }
          it_behaves_like "a statemachine", :rejected, [] { test_context.call }
          it_behaves_like "a statemachine", :received, [:cancelled] { test_context.call }
          it_behaves_like "a statemachine", :confirmed, [:stored, :cancelled] { test_context.call }
          it_behaves_like "a statemachine", :stored, [] { test_context.call }
          it_behaves_like "a statemachine", :cancelled, [] { test_context.call }
        end
        context "where local_node==to_node" do
          # This scenario is addressed above
          # In the context of "put comes from local_node / where local_node=to_node"
        end
        context "where local_node is unimplicated" do
          before(:each) do
            @repl = Fabricate(:replication_transfer, to_node: @to_node, from_node: Fabricate(:node))
            @post_body = build_post_body(@repl, :requested)
          end
          it "responds with 403" do
            put :update, @post_body
            expect(response).to have_http_status(403)
          end
          it "does not update/create the record" do
            put :update, @post_body
            instance = ReplicationTransfer.find_by_replication_id(@repl[:replication_id])
            expect(instance).to eql(@repl)
          end
        end
      end
    end

    describe "basic tests" do
      before(:each) do
        @request.headers["Content-Type"] = "application/json"
        @existing_repl = Fabricate(:replication_transfer)
        @post_body = build_post_body(@existing_repl, :cancelled)
      end

      context "without authorization" do
        it "responds with 401" do
          put :update, @post_body
          expect(response).to have_http_status(401)
        end
        it "does not update the record" do
          put :update, @post_body
          instance = ReplicationTransfer.find_by_replication_id(@existing_repl[:replication_id])
          expect(instance).to eql(@existing_repl)
        end
      end

      context "with authorization" do
        before(:each) do
          token = Faker::Code.isbn
          @auth_node = Fabricate(:node, private_auth_token: token)
          @request.headers["Authorization"] = "Token token=#{token}"
        end
        context "body has old timestamps" do
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
            instance = ReplicationTransfer.find_by_replication_id(@existing_repl[:replication_id])
            expect(instance).to eql(@existing_repl)
          end
        end
        context "record does not exist" do
          before(:each) do
            @post_body[:replication_id] = "nonexistentreplicationid"
          end
          it "responds with 404" do
            put :update, @post_body
            expect(response).to have_http_status(404)
          end
          it "does not update/create the record" do
            put :update, @post_body
            instance = ReplicationTransfer.find_by_replication_id(@existing_repl[:replication_id])
            expect(instance).to eql(@existing_repl)
            expect(ReplicationTransfer.find_by_replication_id(@post_body[:replication_id])).to be_nil
          end
        end

        context "put comes from neither local_ nor to_node" do
          it "responds with 403" do
            put :update, @post_body
            expect(response).to have_http_status(403)
          end
          it "does not update the record" do
            put :update, @post_body
            instance = ReplicationTransfer.find_by_replication_id(@existing_repl[:replication_id])
            expect(instance).to eql(@existing_repl)
          end
        end

      end
    end
  end

  describe "PUT #set_bag_mgr_request" do
    before(:each) do
      @repl = Fabricate(:replication_transfer)
      @id = rand(10000)
    end

    context "without authorization" do
      subject { put :set_bag_mgr_request, id: @repl.id, bag_mgr_request_id: @id }
      it "responds with 401" do
        subject()
        expect(response).to have_http_status(401)
      end
      it "does not display data" do
        subject()
        expect(response).to render_template(nil)
      end
      it "does not create the record" do
        subject()
        expect(ReplicationTransfer.where(bag_mgr_request_id: @id)).to be_empty
      end
    end

    context "with authorization" do
      context "as non-local node" do
        before(:each) do
          @auth_node = Fabricate(:node)
          @request.headers["Authorization"] = "Token token=#{@auth_node.auth_credential}"
        end
        subject { put :set_bag_mgr_request, id: @repl.id, bag_mgr_request_id: @id }

        it "responds with 403" do
          subject()
          expect(response).to have_http_status(403)
        end
        it "does not create the record" do
          subject()
          expect(ReplicationTransfer.where(bag_mgr_request_id: @id)).to be_empty
        end
      end

      context "as local node" do
        before(:each) do
          @auth_node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
          @request.headers["Authorization"] = "Token token=#{@auth_node.auth_credential}"
        end

        context "without pre-existing record" do
          subject { put :set_bag_mgr_request, id: rand(10000), bag_mgr_request_id: @id }
          it "responds with 404" do
            subject()
            expect(response).to have_http_status(404)
          end
          it "renders nothing" do
            subject()
            expect(response).to render_template(nil)
          end
          it "does not create the record" do
            subject()
            expect(ReplicationTransfer.where(bag_mgr_request_id: @id)).to be_empty
          end
        end

        context "with pre-existing record" do
          subject { put :set_bag_mgr_request, id: @repl.id, bag_mgr_request_id: @id }
          context "with id not already assigned" do
            it "responds with 200" do
              subject()
              expect(response).to have_http_status(200)
            end
            it "assigns the id to the record" do
              subject()
              expect(@repl.reload.bag_mgr_request_id).to eql(@id)
            end
          end
          context "with id already assigned" do
            before(:each) do
              @repl.bag_mgr_request_id = rand(10000)
              @repl.save!
            end
            it "responds with 409" do
              subject()
              expect(response).to have_http_status(409)
            end
            it "does not change the id" do
              subject()
              expect(@repl.reload.bag_mgr_request_id).to_not eql(@id)
            end
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @repl = Fabricate(:replication_transfer)
    end
    context "without authorization" do
      subject { delete :destroy, replication_id: @repl.replication_id }
      it "responds with 401" do
        subject()
        expect(response).to have_http_status(401)
      end
      it "does not delete the record" do
        subject()
        expect(ReplicationTransfer.find_by_replication_id(@repl.replication_id)).to be_valid
      end
    end
    context "with authorization" do
      subject { delete :destroy, replication_id: @repl.replication_id }
      context "as non-local node" do
        before(:each) do
          @node = Fabricate(:node)
          @request.headers["Authorization"] = "Token token=#{@node.auth_credential}"
        end
        it "responds with 403" do
          subject()
          expect(response).to have_http_status(403)
        end
        it "does not delete the record" do
          subject()
          expect(ReplicationTransfer.find_by_replication_id(@repl.replication_id)).to be_valid
        end
      end
      context "as local node" do
        before(:each) do
          @node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
          @request.headers["Authorization"] = "Token token=#{@node.auth_credential}"
        end
        context "without pre-existing record" do
          subject { delete :destroy, replication_id: Faker::Code.isbn }
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
          subject { delete :destroy, replication_id: @repl.replication_id }
          it "responds with 204" do
            subject()
            expect(response).to have_http_status(204)
          end
          it "deletes the bag" do
            subject()
            expect(ReplicationTransfer.find_by_replication_id(@repl.replication_id)).to be_nil
          end
        end
      end
    end
  end
end

