# encoding: utf-8

class AudioFileUploader < CarrierWave::Uploader::Base
  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  def store_dir
    "#{model.collection_title}/audio_files"
  end

  def extension_white_list
    ['mp3', 'wav', 'mp2', 'aac']
  end
end
