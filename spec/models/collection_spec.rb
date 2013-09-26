require 'spec_helper'

describe Collection do

  it "should be valid with default attributes" do
    @collection = FactoryGirl.build :collection
    @collection.save.should be_true
  end

  it "should set storage" do
    @collection = FactoryGirl.build :collection
    @collection.upload_to.should_not be_nil
    @collection.upload_storage.should_not be_nil
    @collection.default_storage.should_not be_nil
    @collection.default_storage.should_not eq @collection.upload_storage
  end

  it "should set org based on creator" do
    @creator = FactoryGirl.create :organization_user
    @creator.organization.should_not be_nil

    @collection = FactoryGirl.create :collection, creator: @creator
    @collection.run_callbacks(:commit)
    @collection.creator.should eq @creator
    @collection.collection_grants.count.should eq 1
  end

  it "can be for uploads" do
    @creator = FactoryGirl.create :user
    @creator.uploads_collection.should be_uploads_collection
  end

end
