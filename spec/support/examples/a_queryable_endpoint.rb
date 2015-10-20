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
  let(:val) { model.send(key) }
  before(:each) do
    @params = {page: 1, page_size: page_size}
  end 

  context "with param #{key}" do
    before(:each) do
      @params[key] = val
    end

    it "responds with 200" do
      get :index, @params
      expect(response).to have_http_status(200)
      expect(response.content_type).to eql("application/json")
    end 

    it "contains the model" do
      get :index, @params
      response_obj = JSON.parse(response.body)
      # As of now we only expect one, but that could change...
      # Might want to find a better solution than this
      # (i.e. multiple models to find -> count.eq models.size,
      #                               -> results includes models)
      expect(response_obj['count']).to eql(1)
      expect(response_obj['results'][0][key.to_s]).to eql(val)
    end 
  end
end
