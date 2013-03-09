require 'pb_core'

namespace :import do

  desc "Import PBCore 2.0 pbcoreDescriptionDocument XML file from Omeka"
  task :pbcore_omeka_doc, [:collection_id, :file] => [:environment] do |t, args|
    importer = PBCoreImporter.new(collection_id: args.collection_id, file: args.file)
    importer.import_omeka_description_document
  end


  desc "Import PBCore 2.0 pbcoreCollection XML file from Omeka"
  task :pbcore_omeka_collection, [:collection_id, :file] => [:environment] do |t, args|
    importer = PBCoreImporter.new(collection_id: args.collection_id, file: args.file)
    importer.import_omeka_collection
  end

end
