require 'spec_helper'

describe CollectionGrant do
  before { StripeMock.start }
  after { StripeMock.stop }

  context "basics" do
    it "should have collector user" do
      @collection = FactoryGirl.create :collection
      @user = FactoryGirl.create :user
      @collection_grant = CollectionGrant.create(collection: @collection, collector: @user)
      @user.collections.first.should eq @collection
    end

    it "should have collector org" do
      @collection = FactoryGirl.create :collection
      @organization = FactoryGirl.create :organization
      @collection_grant = CollectionGrant.create(collection: @collection, collector: @organization)
      @organization.collections.first.should eq @collection
    end

  end

end
