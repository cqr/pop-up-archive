# encoding: utf-8

class AudioFileUploader < CarrierWave::Uploader::Base
  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  def extension_white_list
    ['mp3', 'wav', 'mp2', 'aac']
  end

  def store_dir
    if use_folders?
      "#{model.item.token}/audio_files"
    else
      ''
    end
  end

  def fog_directory
    !model.storage.nil? ? model.storage.bucket : CarrierWave::Uploader::Base.fog_directory
  end

  def fog_credentials
    model.storage.nil? ? CarrierWave::Uploader::Base.fog_credentials : model.storage.credentials
  end

  def provider
    self.fog_credentials[:provider]
  end

  def use_folders?
    case provider.downcase
    when 'aws' then true
    when 'internetarchive' then false
    else true
    end
  end

end
