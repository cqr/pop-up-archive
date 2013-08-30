require 'spec_helper'

describe FeedPopUp do

  it "should be constructed with dry_run option" do
    FeedPopUp.new.dry_run.should == false
    FeedPopUp.new(true).dry_run.should == true
  end

  it "should process a feed" do
    collection = FactoryGirl.create :collection_private
    url = 'http://radio.seti.org/index.xml'
    fpu = FeedPopUp.new(true)
    fpu.parse(url, collection.id)
  end

end
