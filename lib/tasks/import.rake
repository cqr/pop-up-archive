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

  desc "Import Open Vault xml files from a directory"
  task :import_xml_openvault_dir, [:collection_id, :dir] => [:environment] do |t, args|
    importer = XMLMediaImporter.new(collection_id: args.collection_id, dir: args.dir)
    importer.import_openvault_directory
  end

  desc "Import Illinois Collection XML file "
  task :import_xml_illinois_collection, [:collection_id, :file] => [:environment] do |t, args|
    importer = XMLMediaImporter.new(collection_id: args.collection_id, file: args.file)
    importer.import_xml_illinois_collection
  end

  desc "Import BBG Collection XML file "
  task :import_xml_bbg_feed, [:collection_id, :file] => [:environment] do |t, args|
    importer = XMLMediaImporter.new(collection_id: args.collection_id, file: args.file)
    importer.import_xml_bbg_feed
  end


end
