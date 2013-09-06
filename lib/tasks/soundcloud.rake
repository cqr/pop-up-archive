require 'pb_core'

namespace :soundcloud do

  desc "Generate link authorization url"
  task :generate_link => :environment do
    SoundcloudBackend.get_url
  end

  desc "Import from soundcloud"
  task :import_url, [:collection_id, :url] => [:environment] do |t, args|
    SoundcloudBackend.import_url(args.url, args.collection_id)
  end


end
