class PBCoreImporter

  attr_accessor :file, :collection

  def initialize(options={})
    PBCore.config[:date_format] = '%m/%d/%Y'

    raise "File missing or 0 length: #{options[:file]}" unless (File.size?(options[:file]).to_i > 0)

    self.collection = Collection.find(options[:collection_id])
    self.file = File.open(options[:file])
  end

  def import_omeka_description_document
    doc = PBCore::V2::DescriptionDocument.parse(file)
    item_for_omeka_doc(doc).save!
  end

  def import_omeka_collection
    pbc_collection = PBCore::V2::Collection.parse(file)
    pbc_collection.description_documents.each do |doc|
      item_for_omeka_doc(doc).save!
    end
  end

  def item_for_omeka_doc(doc)
    item = Item.new
    item.collection        = collection
    item.date_created      = doc.detect_element(:asset_dates, match_value: ['created', nil], value: :date)
    item.identifier        = doc.detect_element(:identifiers)
    item.episode_title     = doc.detect_element(:titles, match_value: 'episode', default_first: false)
    item.series_title      = doc.detect_element(:titles, match_value: 'series', default_first: false)
    item.title             = doc.detect_element(:titles)
    item.tags              = doc.subjects.collect{|s| s.value}.compact
    item.description       = doc.detect_element(:descriptions)
    item.physical_location = doc.detect_element(:coverages, match_value: 'spatial', value: :info, default_first: false).try(:value)
    item.creators          = doc.creators.collect{|c| Person.for_name(c.name.value)}
    item.contributions     = doc.contributors.collect{|c| Contribution.new(person:Person.for_name(c.name.value), role:c.role.value)}
    item.rights            = doc.rights.collect{|r| [r.summary.try(:value), r.link.try(:value), r.embedded.try(:value)].compact.join("\n") }.compact.join("\n")
    item.notes             = doc.detect_element(:annotations, match_value: 'notes', default_first: false)
    item.transcription     = doc.detect_element(:annotations, match_value: 'transcript', default_first: false)

    # process each instance
    doc.instantiations.each do |pbcInstance|
      next if pbcInstance.digital.nil?

      instance = item.instances.build
      instance.digital    = true
      instance.format     = pbcInstance.digital.value
      instance.identifier = pbcInstance.detect_element(:identifiers)
      instance.location   = pbcInstance.location

      if pbcInstance.parts.blank?
        audio = AudioFile.new
        instance.audio_files << audio
        item.audio_files << audio
        audio.identifier        = pbcInstance.detect_element(:identifiers)
        audio.remote_file_url   = pbcInstance.location
        audio.format            = pbcInstance.digital.value
        audio.size              = pbcInstance.file_size.try(:value).to_i
      else
        pbcInstance.parts.each do |pbcPart|
          audio = AudioFile.new
          instance.audio_files << audio
          item.audio_files << audio
          audio.identifier        = pbcPart.detect_element(:identifiers, match_attr: :source, match_value: /item_id$/)
          audio.remote_file_url   = pbcPart.location
          audio.format            = pbcPart.digital.value
          audio.size              = pbcPart.file_size.try(:value).to_i
        end   
      end

      item.instances << instance

    end
    item
  end

end