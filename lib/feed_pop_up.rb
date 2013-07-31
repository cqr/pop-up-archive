class FeedPopUp
  def self.update_from_feed(feed_url, collection_id)
    feed = Feedzirra::Feed.fetch_and_parse([feed_url])
    add_entries(feed.entries, collection_id)
  end

  private
  def self.is_audio_file?(url)
    #puts "is_audio_file? url:#{url}"
    uri = URI.parse(url)
    ext = (File.extname(uri.path)[1..-1] || "").downcase
    ['aac', 'aif', 'aiff', 'alac', 'flac', 'm4a', 'm4p', 'mp2', 'mp3', 'mp4', 'ogg', 'raw', 'spx', 'wav', 'wma'].include?(ext)
  rescue  URI::BadURIError
    false
  rescue  URI::InvalidURIError
    false
  end


  def self.add_entries(entries, coll_id)
    entries.each do |entry|
      unless Item.where(identifier: entry.id,collection_id:  coll_id).exists?
        item = Item.new
        item.collection =  Collection.find(coll_id)
        item.description = entry.summary
        item.title = entry.title
        item.identifier = entry.id
        item.digital_location = entry.url
        item.date_broadcast = entry.published
        entry.media_contents.each  do |mediaContent|
          url = mediaContent.url
          next unless self.is_audio_file?(url)
          instance = item.instances.build
          instance.digital = true
          audio = AudioFile.new
          instance.audio_files << audio
          item.audio_files << audio
          audio.identifier = url
          audio.remote_file_url= url
        end
        item.save!

      end
    end
  end
end
