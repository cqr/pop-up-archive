require 'amara'

def amara_client
  Amara::Client.new(
    api_key:      ENV['AMARA_KEY'],
    api_username: ENV['AMARA_USERNAME'],
    endpoint:     ENV['AMARA_ENDPOINT']
  )
end