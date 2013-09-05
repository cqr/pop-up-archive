class SoundcloudBackend
  def self.get_url
    client = Soundcloud.new({
                                :client_id      => ENV['SOUNDCLOUD_SERVER_APP_ID'] ,
                                :client_secret  =>  ENV['SOUNDCLOUD_SERVER_APP_SECRET'],
                                :redirect_uri =>  ENV['SOUNDCLOUD_POP_REDIRECT_URL']
                            })
    puts client.authorize_url()
  end

  def self.import_url(soundcloud_url, collection_id)
    collection = Collection.find(collection_id)
    client = Soundcloud.new(:client_id =>  ENV['SOUNDCLOUD_SERVER_APP_ID'] ,:access_token =>\ ENV['SOUNDCLOUD_POPUPARCHIVE_USER_ACCESS_TOKEN'])
    station = client.get('/resolve', :url => soundcloud_url, client_id: ENV['SOUNDCLOUD_SERVER_APP_ID'])
    tracks = client.get("/users/#{station.id}/tracks")

    tracks.each do |track|
      if track.downloadable
        item = Item.new
        item.collection = collection
        item.date_created = track.created_at
        item.title = track.title
        item.description = track.description

        instance = item.instances.build
        instance.digital    = true
        instance.format     = track.original_format
        instance.identifier = track.id

        audio = AudioFile.new
        instance.audio_files << audio
        item.audio_files << audio
        audio.identifier        =  track.download_url+"?client_id="+ENV['SOUNDCLOUD_SERVER_APP_ID']
        audio.remote_file_url   =  track.download_url+"?client_id="+ENV['SOUNDCLOUD_SERVER_APP_ID']
        item.save!
      end
    end
  end

end