require "spec_helper"

describe Endpoints::Tables do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  def schema_path
    "./schema/schema.json"
  end

  describe 'GET /tables' do
    it 'returns correct status code and conforms to schema' do
      get '/tables'
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'POST /tables' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      post '/tables', MultiJson.encode({})
      assert_equal 201, last_response.status
      assert_schema_conform
    end
  end

  describe 'GET /tables/:id' do
    it 'returns correct status code and conforms to schema' do
      get "/tables/123"
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'PATCH /tables/:id' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      patch '/tables/123', MultiJson.encode({})
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'DELETE /tables/:id' do
    it 'returns correct status code and conforms to schema' do
      delete '/tables/123'
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end
end
