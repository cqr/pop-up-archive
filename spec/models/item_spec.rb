require 'spec_helper'

describe Item do
  context "#geographic_location" do
    it "= should set the geolocation using Geoloation.for_name" do
      Geolocation.should_receive(:for_name).with("Cambridge, MA")
      FactoryGirl.build :item, geographic_location: "Cambridge, MA"
    end

    it "should return the string name of the associated geolocation" do
      record = FactoryGirl.create :item, geographic_location: "Madison, WI"

      record.geographic_location.should eq "Madison, WI"
    end
  end

  it "should allow writing to the extra attributes" do
    item = Item.new(FactoryGirl.attributes_for :item)
    item.extra['testkey'] = 'test value'
    item.save
  end

  it 'should persist the extra attributes'
end
