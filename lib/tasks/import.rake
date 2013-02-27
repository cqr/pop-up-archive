require 'pb_core'

namespace :import do

  desc "Import PBCore 2.0 XML from Omeka"
  task :pbcore_20_omeka, [:collection_id, :file_name] => [:environment] do |t, args|

    # find the collection
    collection = Collection.find(args.collection_id)

    # check to make sure the file exists
    raise "File missing or 0 length: #{args.file_name}" unless (File.size?(args.file_name).to_i > 0)

    # set PBCore defaults
    PBCore.config[:date_format] = '%m/%d/%Y'

    # open and parse the xml file
    f = File.open(args.file_name)
    doc = PBCore::V2::DescriptionDocument.parse(f)

    i = Item.new
    i.collection        = collection
    i.date_created      = doc.detect_element(:asset_dates, :type, ['created', nil]).try(:date)
    i.identifier        = doc.detect_element(:identifiers, :source).try(:value)
    i.episode_title     = doc.detect_element(:titles, :type, 'episode', false).try(:value)
    i.series_title      = doc.detect_element(:titles, :type, 'series', false).try(:value)
    i.title             = doc.detect_element(:titles).try(:value)
    i.tags              = doc.subjects.collect{|s| s.value}.compact
    i.description       = doc.detect_element(:descriptions).try(:value)
    i.physical_location = doc.detect_element(:coverages, :type, 'spatial', false).try(:info).try(:value)
    i.creators          = doc.creators.collect{|c| Person.for_name(c.name.value)}
    i.contributions     = doc.contributors.collect{|c| Contribution.new(person:Person.for_name(c.name.value), role:c.role.value)}
    i.rights            = doc.rights.collect{|r| [r.summary.try(:value), r.link.try(:value), r.embedded.try(:value)].compact.join("\n") }.compact.join("\n")
    i.notes             = doc.detect_element(:annotations, :type, ['notes']).try(:value)
    i.transcription     = doc.detect_element(:annotations, :type, ['transcript']).try(:value)

    # process each instance
    doc.instantiations.each do |pbcInstance|
      instance = i.instances.build

      if pbcInstance.digital.try(:value)
        instance.digital = true
        instance.format = pbcInstance.digital.value
      elsif pbcInstance.physical.try(:value)
        instance.digital = false
        instance.format = pbcInstance.physical.value
      end

      instance.identifier = pbcInstance.detect_element(:identifiers, :source).try(:value)
      instance.location = pbcInstance.location

      if pbcInstance.parts.blank?
        audio = instance.audio_files.build
        audio.identifier        = pbcInstance.detect_element(:identifiers, :source).try(:value)
        audio.original_file_url = pbcInstance.location
        audio.size              = pbcInstance.file_size.try(:value)
      else
        pbcInstance.parts.each do |pbcPart|
          audio = instance.audio_files.build
          audio.identifier        = pbcPart.detect_element(:identifiers, :source, [/item_id$/]).try(:value)
          audio.original_file_url = pbcPart.detect_element(:identifiers, :source, [/original_filename$/]).try(:value)
          audio.url               = pbcPart.location
          audio.format            = pbcPart.digital.value
          audio.size              = pbcPart.file_size.try(:value).to_i
          puts "pbcPart.file_size: #{pbcPart.file_size.inspect}, audio.size: #{audio.size}"
        end   
      end

      i.instances << instance

    end

    i.save!    
    puts i.inspect
  end

end
