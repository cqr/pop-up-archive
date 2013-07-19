require 'pb_core'

namespace :import do

  desc "FTP loader"
  task :ftp_folder, [:collection_id, :url, :folder, :user, :password, :first_item, :last_item] => [:environment] do |t, args|
    importer = RemoteImporter.new(collection_id: args.collection_id, url: args.url, folder: args.folder, user: args.user, password: args.password, first_item: args.first_item, last_item: args.last_item )
    importer.get_ftp_folder
  end
end
