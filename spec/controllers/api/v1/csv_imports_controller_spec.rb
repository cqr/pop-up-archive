require 'spec_helper'
describe Api::V1::CsvImportsController do
  before :each do
    request.accept = "application/json"
  end


  describe "POST 'create'" do

    before :each do
      @valid_attributes = FactoryGirl.attributes_for :csv_import
    end

    it "returns http success with valid attributes" do
      post 'create', csv_import: @valid_attributes
      response.should be_success
    end

    [:csv_import_with_bad_file, :csv_import_with_no_file].each do |type_of_failed_import|

      it "returns http failure with a #{type_of_failed_import.to_s.gsub('_',' ')}" do
        post 'create', csv_import: FactoryGirl.attributes_for(type_of_failed_import)
        response.code.should eq "422"
      end

    end
  end
end
