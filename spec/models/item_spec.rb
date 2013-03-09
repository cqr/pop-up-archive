require 'spec_helper'

describe Item do
  context "#geographic_location" do
    it "should set the geolocation using Geoloation.for_name" do
      Geolocation.should_receive(:for_name).with("Cambridge, MA")
      FactoryGirl.build :item, geographic_location: "Cambridge, MA"
    end

    it "should return the string name of the associated geolocation" do
      record = FactoryGirl.create :item, geographic_location: "Madison, WI"

      record.geographic_location.should eq "Madison, WI"
    end
  end

  it "should allow writing to the extra attributes" do
    item = FactoryGirl.build :item
    item.extra['testkey'] = 'test value'
    item.save
  end

  it 'should persist the extra attributes' do
    item = FactoryGirl.create :item
    item.extra['testKey'] = 'testValue2'
    item.save

    Item.find(item.id).extra['testKey'].should eq 'testValue2'
  end

  it "should create a unique token fromthe title and keep it" do
    item = FactoryGirl.build :item
    item.title = 'test'
    item.token.should start_with('test_')
    item.title = 'test2'
    item.token.should start_with('test_')
  end

end
