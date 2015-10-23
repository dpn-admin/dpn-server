# Copyright statement here
# With cool copyright words
# Legal agreements yay

## TODO: When the restoration_resource branch is merged in, we can use some of 
#        the other helpers to make this a bit cleaner. i.e., use the factory 
#        to generate models for the db to query (that way we don't need to rely
#        on the model variable as an outside entity)
#
#        We can also send the verb/action (:get, :index), but since this will only
#        really happen on an index I'm not sure if that's necessary.
shared_examples "a queryable endpoint" do |key|
  raise ArgumentError, "Missing required parameters" unless key
  page_size = 2
  before(:each) do
    @model = Fabricate(factory)
    @other_model = Fabricate(factory)
    @params = {page: 1, page_size: page_size}
  end

  context "with param #{key}" do
    before(:each) do
      @params[key] = @model.send(key)
    end

    it "responds with 200" do
      get :index, @params
      expect(response).to have_http_status(200)
      expect(response.content_type).to eql("application/json")
    end 

    it "assigns the correct object to @#{factory.to_s.pluralize}" do
      get :index, @params
      assignee = assigns(:"#{factory.to_s.pluralize}")
      expect(assignee).to respond_to(:size)
      expect(assignee).to include(@model)
    end

    it "doesn't assign incorrect objects to @#{factory.to_s.pluralize}" do
      get :index, @params
      assignee = assigns(:"#{factory.to_s.pluralize}")
      expect(assignee).to respond_to(:size)
      expect(assignee).to_not include(@other_model)
    end
  end
end
