require "spec_helper"

describe Endpoints::Tables do
  include Rack::Test::Methods

  describe "GET /tables" do
    it "succeeds" do
      get "/tables"
      assert_equal 200, last_response.status
    end
  end
end
