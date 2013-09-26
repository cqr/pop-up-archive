require 'spec_helper'

describe User do

  let(:user) { FactoryGirl.create :user }

  it 'gets a holding collection automatically' do
    user.uploads_collection.should_not be_nil
  end

  context '#uploads_collection' do
    it 'is a collection' do
      user.uploads_collection.should be_a Collection
    end

    it 'returns the same collection across multiple calls' do
      user.uploads_collection.should eq user.uploads_collection
    end

    it 'is persisted in the database' do
      user.uploads_collection.should be_persisted
    end

    it 'works when the user is not saved' do
      user = FactoryGirl.build :user
      user.uploads_collection.should eq user.uploads_collection
    end

    it 'saves with the user' do
      user = FactoryGirl.build :user
      collection = user.uploads_collection

      user.save.should be true

      user.should be_persisted
      collection.should be_persisted
      user.uploads_collection.should eq collection
      user.uploads_collection.creator.should eq user
    end

  end

  context "in an organization" do
    it "allows org admin to order transcript" do
      audio_file = AudioFile.new

      ability = Ability.new(user)
      ability.should_not be_can(:order_transcript, audio_file)

      user.organization = FactoryGirl.create :organization

      ability = Ability.new(user)
      ability.should_not be_can(:order_transcript, audio_file)

      user.add_role :admin, user.organization

      ability = Ability.new(user)
      ability.should be_can(:order_transcript, audio_file)
    end

    it 'gets upload collection from the organization' do
      user = FactoryGirl.create :organization_user
      user.organization.run_callbacks(:commit)
      user.uploads_collection.should eq user.organization.uploads_collection
    end

    it "gets list of collections from the organization" do
      user = FactoryGirl.create :organization_user
      organization = user.organization
      organization.run_callbacks(:commit)
      organization.collections.count.should eq 1
      organization.collections << FactoryGirl.create(:collection)
      organization.collections.count.should eq 2
      user.collections.should eq organization.collections
      user.collection_ids.should eq organization.collections.collect(&:id)
    end

  end

end
