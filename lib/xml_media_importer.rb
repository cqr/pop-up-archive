require 'nokogiri'

class XMLMediaImporter

  attr_accessor :file, :collection,:collection_id, :dir, :file_name, :max_items_per_collection, :filter

  def initialize(options={})
    #PBCore.config[:date_formats] = ['%m/%d/%Y', '%Y-%m-%d']
    if options.has_key?(:filter)
      self.collection_id = options[:collection_id]
      self.file_name = options[:file]
      self.filter = options[:filter]
      self.max_items_per_collection = Integer(options[:max])
    else
      self.collection = Collection.find(options[:collection_id])
    end
    directory = options[:dir] ||= nil

    if directory == nil
      raise "File missing or 0 length: #{options[:file]}" unless (File.size?(options[:file]).to_i > 0)
      self.file = File.open(options[:file])
      #self.dir = Dir[options[:file]+"*.xml"]
    else
      self.dir = Dir[directory+"/*.xml"]
    end

  end

  def is_audio_file?(url)
    puts "is_audio_file? url:#{url}"
    uri = URI.parse(url)
    ext = (File.extname(uri.path)[1..-1] || "").downcase
    ['mp3', 'wav', 'mp2', 'aac'].include?(ext)
  end

  def import_xml_illinois_collection
    xmlFeed=Nokogiri::XML(file)
    xmlFeed.remove_namespaces!
    descriptions = xmlFeed.xpath("//PBCoreCollection/PBCoreDescriptionDocument")
    descriptions.each do |pbcoreDescription|
      item_for_illinois_doc(pbcoreDescription).save!
    end
  end

  def filter_ks_xml_file

    item_count = 0
    mode=nil
    mode = filter.slice! 'ONLY' if filter.match('ONLY')
    mode = filter.slice! 'OMIT' if filter.match('OMIT')

    raise 'unsupported filtering mode' if mode.nil?

    filter.strip!
    filter.downcase!

    omeka_importer = PBCoreImporter.new(collection_id: self.collection_id, file: self.file_name)
    pbc_collection = PBCore::V2::Collection.parse(file)
    pbc_collection.description_documents.each do |doc|
      break if item_count >= self.max_items_per_collection
      unless doc.instantiations.to_a.empty?
        # there are several types of identifiers on the ks file witt references to F-B. small changes on them are probably not expected.
        url = doc.instantiations[0].detect_element(:identifiers, match_attr: :source, match_value: ['URL', nil])
        url.downcase!
        if mode == 'ONLY' and url.match(filter)
          item_count += 1
          omeka_importer.item_for_omeka_doc(doc).save!
        end
        if mode == 'OMIT' and not url.match(filter)
          item_count += 1
          omeka_importer.item_for_omeka_doc(doc).save!
        end
      end
    end
  end

  def import_xml_bbg_feed
    # pbc_collection = PBCore::V2::Collection.parse(file)
    xmlFeed=Nokogiri::XML(file)
    xmlFeed.remove_namespaces!
    items = xmlFeed.xpath("//item")
    items.each do |item|
      sleep(2)
      item_for_bbg(item).save!
    end
  end


  def import_openvault_directory
    # pbc_collection = PBCore::V2::Collection.parse(file)
    dir.each do |xmlfile|
      file = File.open(xmlfile.to_s)
      xmlFeed=Nokogiri::XML(file)
      #to simplify xpath queries, try to remove namespaces
      #it might not work for files with multiples namespaces
      xmlFeed.remove_namespaces!
      item_for_openvault(xmlFeed).save!
    end
  end


  def item_for_illinois_doc(doc)
    item = Item.new
    item.collection = collection
    item.title = doc.search('title')[0].text
    item.tags = doc.search('subject').collect { |s| s.text }.compact
    item.description = doc.xpath("pbcoreDescription[descriptionType='Abstract']/description").text
    item.physical_location = doc.xpath("pbcoreCoverage[coverageType='Spatial']/coverage").text
    item.creators = doc.xpath("pbcoreCreator/creator").collect { |s| Person.for_name(s.text) }
    item.contributions = doc.xpath("pbcoreContributor").collect { |s| Contribution.new(person: Person.for_name(s.xpath("contributor").text), role: s.xpath("contributorRole").text) }
    mediaContents = doc.xpath("//pbcoreInstantiation[not(instantiationPhysical)]")
		mediaContents.each do |mediaContent|
		  url = mediaContent.xpath("instantiationLocation").text
			next unless is_audio_file?(url)
			audio = AudioFile.new
			instance = item.instances.build
			instance.digital = true
			#instance.format     = pbcInstance.try(:digital).try(:value)
			#instance.identifier = pbcInstance.detect_element(:identifiers)
			#instance.location   = pbcInstance.location
			audio = AudioFile.new
			instance.audio_files << audio
			item.audio_files << audio
			audio.identifier = url
			audio.remote_file_url= url
			#audio.format        = pbcPart.try(:digital).try(:value) || instance.format
			#audio.size          = mediaContent.attribute('fileSize').value
		end
  end

  def item_for_openvault(doc)
    item = Item.new
    item.collection = collection
    #Alternative xpath, only works for some files doc.xpath("//pbcoreTitle[@titleType = 'Series']").text
    item.title = doc.xpath("//pbcoreTitle[not(@titleType='Episode')]").collect { |s| s.text }.join(" ")[0, 255]
    item.tags = doc.xpath("//pbcoreSubject").collect { |s| s.text[0, 255] }.compact || []
    item.physical_location = doc.xpath("pbcoreCoverage[coverageType='Spatial']/coverage").text
    item.description = doc.xpath("//pbcoreDescription[@descriptionType='Description']").text
    #item.creators         = doc.xpath("credit").collect{|s| Person.for_name(s.text)}
    item.contributions = doc.xpath("pbcoreContributor").collect { |s| Contribution.new(person: Person.for_name(s.xpath("contributor").text), role: s.xpath("contributorRole").text) }
    mediaContents = doc.xpath("//pbcoreInstantiation[not(instantiationPhysical)]")
    mediaContents.each do |mediaContent|
      url = mediaContent.xpath("instantiationLocation").text
      next unless is_audio_file?(url)
      audio = AudioFile.new
      instance = item.instances.build
      instance.digital = true
      #instance.format     = pbcInstance.try(:digital).try(:value)
      #instance.identifier = pbcInstance.detect_element(:identifiers)
      #instance.location   = pbcInstance.location
      audio = AudioFile.new
      instance.audio_files << audio
      item.audio_files << audio
      audio.identifier = url
      audio.remote_file_url= url
      #audio.format        = pbcPart.try(:digital).try(:value) || instance.format
      #audio.size          = mediaContent.attribute('fileSize').value
    end
    item
  end

  def item_for_bbg(doc)
    item = Item.new
    item.collection = collection
    item.title = doc.xpath("title").text
    item.tags = doc.xpath("keywords").collect { |s| s.text.split(/,|;/) }.flatten.compact.uniq.delete_if(&:empty?)
    item.tags.concat(doc.xpath("category").collect { |s| s.text.split(/,|;|&gt|\>/) }.flatten.compact.uniq.delete_if(&:empty?))
    item.description = doc.xpath("description").text
    # VOA is not a person, but it is the closest thing to a creator on the BBG file
    item.creators = doc.xpath("credit").collect { |s| Person.for_name(s.text) }
    #item.contributions     = doc.xpath("pbcoreContributor").collect{|s| Contribution.new(person:Person.for_name(s.xpath("contributor").text),role:s.xpath("contributorRole").text)}
    mediaContents = doc.xpath("group/content")
    mediaContents.each do |mediaContent|
      url = mediaContent.attribute('url').value
      next unless is_audio_file?(url)
      audio = AudioFile.new
      instance = item.instances.build
      instance.digital = true
      #instance.format     = pbcInstance.try(:digital).try(:value)
      #instance.identifier = pbcInstance.detect_element(:identifiers)
      #instance.location   = pbcInstance.location
      audio = AudioFile.new
      instance.audio_files << audio
      item.audio_files << audio
      audio.identifier = url
      audio.remote_file_url = url
      #audio.format            = pbcPart.try(:digital).try(:value) || instance.format
      audio.size = mediaContent.attribute('fileSize').value
    end
		item
  end
end
