class StorageConfiguration < ActiveRecord::Base
  attr_accessible :bucket, :key, :provider, :secret

  validates_presence_of :key, :secret, :provider

  def attributes
    {}
  end

  def credentials
    abbr = abbr_for_provider
    if key && secret && provider && abbr
      options = {
        :provider => provider,
        "#{abbr}_access_key_id".to_sym => key,
        "#{abbr}_secret_access_key".to_sym => secret
      }
    end
  end

  def abbr_for_provider
    case provider.downcase
    when 'aws' then 'aws'
    when 'internetarchive' then 'ia'
    else provider.downcase
    end
  end

  def self.default_storage(is_public=false)
    is_public ? public_storage : private_storage
  end

  def self.public_storage
    @_pub ||= self.new({
      provider: 'InternetArchive',
      key:      ENV['IA_ACCESS_KEY_ID'],
      secret:   ENV['IA_SECRET_ACCESS_KEY']
    })
  end

  def self.private_storage
    @_priv ||= self.new({
      provider: 'AWS',
      key:      ENV['AWS_ACCESS_KEY_ID'],
      secret:   ENV['AWS_SECRET_ACCESS_KEY'],
      bucket:   ENV['AWS_BUCKET']
    })
  end

end
