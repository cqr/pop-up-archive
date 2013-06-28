# encoding: utf-8

class AudioFileUploader < CarrierWave::Uploader::Base
  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  def extension_white_list
    ['aac', 'aif', 'aiff', 'alac', 'flac', 'm4a', 'm4p', 'mp2', 'mp3', 'mp4', 'ogg', 'raw', 'spx', 'wav', 'wma']
  end

  def store_dir
    model.item.try(:token) if use_folders?
  end

  def store_dir
    if use_folders?
      "#{model.item.try(:token)}/#{model.path}"
    else
      nil
    end
  end


  def fog_attributes
    fa = model.storage.attributes
    fa ||= {}

    if provider == 'InternetArchive'
      fa[:collections] = [] unless fa.has_key?(:collections)
      fa[:collections] << 'test_collection' if !Rails.env.production?
      fa[:collections] << 'popuparchive'    if Rails.env.production?
      fa[:ignore_preexisting_bucket] = 1
      fa[:interactive_priority] = 1
      fa[:auto_make_bucket] = 1
      fa[:cascade_delete] = 1
      fa[:subjects] = [model.item.try(:collection).try(:title)]
      fa[:metadata] = {
        'x-archive-meta-title' => model.item.try(:title),
        'x-archive-meta-mediatype' => 'audio'
      }
    end

    fa
  end

  def fog_directory
    use_folders? ? model.storage.bucket : model.item.token
  end

  def fog_public
    model.storage.is_public?
  end

  def use_folders?
    case provider
    when 'AWS' then true
    when 'InternetArchive' then false
    else true
    end
  end

  def provider
    self.fog_credentials[:provider].to_s
  end

  def fog_credentials
    c = model.storage.credentials
    c[:path_style] = true if c[:provider].to_s == 'AWS'
    c
  end

end
