# encoding: utf-8

class AudioFileUploader < CarrierWave::Uploader::Base
  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  def extension_white_list
    ['aac', 'aif', 'aiff', 'alac', 'flac', 'm4a', 'm4p', 'mp2', 'mp3', 'mp4', 'ogg', 'raw', 'spx', 'wav', 'wma']
  end

  def public_url

    puts "!!!! url called !!!!"

    if !asset_host && (provider == "InternetArchive")
      "http://archive.org/download/#{model.destination_directory}#{model.destination_path}"
    else
      super
    end
  end

  def store_dir
    model.store_dir
  end

  def fog_attributes
    # build off these options, set rest that are needed (some are defaults in fixer already)
    fa = model.destination_options
    fa ||= {}

    if provider == 'InternetArchive'
      fa[:collections] = [] unless fa.has_key?(:collections)
      fa[:collections] << 'test_collection' if !Rails.env.production?
      fa[:ignore_preexisting_bucket] = 0
      fa[:interactive_priority] = 1
      fa[:auto_make_bucket] = 1
      fa[:cascade_delete] = 1
    end

    fa
  end

  def fog_directory
    model.destination_directory
  end

  def fog_public
    model.storage.is_public?
  end

  def provider
    model.storage.credentials[:provider].to_s
  end

  def fog_credentials
    c = model.storage.credentials
    c[:path_style] = true if c[:provider].to_s == 'AWS'
    c
  end

end
