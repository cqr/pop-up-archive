require 'spec_helper'

describe Geolocation do
  context ".for_name" do
    it "returns a new record for a new location" do
      Geolocation.for_name("Madison, WI").should be_a Geolocation
    end

    it "returns a persisted record" do
      Geolocation.for_name("Madison, WI").should be_persisted
    end

    context 'with an existing location' do
      before :each do
        @existing_location = FactoryGirl.create(:geolocation, name: "Madison, WI")
      end

      it "returns an existing record when the name is the same" do
        Geolocation.for_name("Madison, WI").should eq @existing_location
      end

      it "returns an existing record when the name has different capitalization" do
        Geolocation.for_name("madison, wi").should eq @existing_location
      end

      it "returns an existing record when the name has different punctuation" do
        Geolocation.for_name("Madison  WI").should eq @existing_location
      end

      it "returns a new record when the name is different" do
        Geolocation.for_name("Portland, OR").should_not be @existing_location
      end
    end
  end

  context "geocoding" do
    it "should trigger geocoding before save when the name has changed" do
      location = FactoryGirl.build(:geolocation)
      location.should_receive(:enqueue_geocode)
      location.save
    end

    it "should not trigger geocoding before save when the name hasn't changed" do
      location = FactoryGirl.create(:geolocation)
      location.should_not_receive(:enqueue_geocode)
      location.touch
    end
  end
end
