class FeedPopUp
  def self.update_from_feed(feed_url, collection_id)
    able_to_parse = true
    feed = Feedzirra::Feed.fetch_and_parse(feed_url)
    feed = Feedzirra::Feed.fetch_and_parse(feed_url, :on_failure => lambda {|url, response_code, header, body| able_to_parse = false if response_code == 200 })
    if able_to_parse && feed && feed != 0
      add_entries(feed.entries, collection_id)
    else
      puts "Error: Check feed url " + feed_url
    end
  end

  private


  def self.add_entries(entries, coll_id)
    collection = Collection.find_by_id(coll_id)
    if collection
      newItems = 0
      entries.each do |entry|
        unless Item.where(identifier: entry.entry_id, collection_id: coll_id).exists?
          item = Item.new
          item.collection = collection
          #item.description =Sanitize.clean(entry.summary,:elements => ['r','div'], :remove_contents => true)
          transformer = lambda do |env|
            node      = env[:node]
            node_name = env[:node_name]

            # Don't continue if this node is already whitelisted or is not an element.
            return if env[:is_whitelisted] || !node.element?

            # Don't continue unless the node is an div.
            return unless node_name. == 'div'


            # We're now certain that this is a div in the summary,
            Sanitize.clean_node!(node)

            # Now that we're sure that this is a valid YouTube embed and that there are
            # no unwanted elements or attributes hidden inside it, we can tell Sanitize
            # to whitelist the current node.
            {:node_whitelist => [node]}
          end

          text = Sanitize.clean(entry.summary,:transformers => transformer, :elements => ['a', 'span'],
                                :attributes => {'a' => ['href', 'title'], 'span' => ['class']},
                                :protocols => {'a' => {'href' => ['http', 'https', 'mailto']}})
          item.description =text
          item.title = entry.title
          item.identifier = entry.id
          item.digital_location = entry.url
          item.date_broadcast = entry.published
          item.date_created = entry.published
          item.creators = [Person.for_name(entry.author)]
          entry.media_contents.each do |mediaContent|
            url = mediaContent.url
            next unless Utils.is_audio_file?(url)
            instance = item.instances.build
            instance.digital = true
            audio = AudioFile.new
            instance.audio_files << audio
            item.audio_files << audio
            audio.identifier = url
            audio.remote_file_url= url
          end
          item.save!
          newItems += 1
        end
      end
      if newItems == 0
        puts "There is nothing new for "+coll_id
      else
        puts  newItems.to_s+" new items for " + coll_id.to_s
      end
    else
      puts "Collection not found!, id: "+coll_id
    end
  end
end
