class StorageConfiguration < ActiveRecord::Base
  attr_accessible :bucket, :key, :provider, :secret

 validates_presence_of :key, :secret, :provider

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
    else nil
    end
  end


end
