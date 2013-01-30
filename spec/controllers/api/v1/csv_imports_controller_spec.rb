require 'spec_helper'
describe Api::V1::CsvImportsController do
  before :each do
    request.accept = "application/json"
  end


  describe "POST 'create'" do
    it "returns http success" do
      post 'create'
      puts response.inspect
      response.should be_success
    end
  end

end
