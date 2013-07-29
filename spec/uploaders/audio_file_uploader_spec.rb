require 'spec_helper'

describe AudioFileUploader do

  context "handle different providers" do

    before :all do
      @collection = FactoryGirl.build :collection

      @item = FactoryGirl.build :item
      @audio_file = FactoryGirl.build :audio_file
      @item.collection = @collection
      @audio_file.item = @item

      @uploader = AudioFileUploader.new(@audio_file)
    end

    it "handles no item storage" do
      @uploader.fog_credentials[:provider].should eq "AWS"
      @uploader.fog_credentials[:aws_access_key_id].should eq ENV['AWS_ACCESS_KEY_ID']
      @uploader.fog_credentials[:aws_secret_access_key].should eq ENV['AWS_SECRET_ACCESS_KEY']
    end
    
    it "handles item storage" do
      @item.storage_configuration = StorageConfiguration.new(provider: 'InternetArchive', key: 'k', secret: 's')
      @item.storage.provider.should eq "InternetArchive"
      @uploader.model.item.should_not be_nil
      @uploader.fog_credentials[:provider].should eq "InternetArchive"
      @uploader.fog_credentials[:ia_access_key_id].should eq 'k'
      @uploader.fog_credentials[:ia_secret_access_key].should eq 's'
    end

  end
end
