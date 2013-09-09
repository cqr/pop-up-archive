class SoundcloudBackend

  def self.get_url
<<<<<<< Updated upstream
    client = soundcloud_client
=======
    client = Soundcloud.new({
                                :client_id     => ENV['SOUNDCLOUD_SERVER_APP_ID'] ,
                                :client_secret => ENV['SOUNDCLOUD_SERVER_APP_SECRET'],
                                :redirect_uri  => ENV['SOUNDCLOUD_POP_REDIRECT_URL']
                            })
>>>>>>> Stashed changes
    puts client.authorize_url()
  end

  def self.import_url(soundcloud_url, collection_id)
    collection = Collection.find(collection_id)
<<<<<<< Updated upstream
    client     = soundcloud_client
=======
    client     = Soundcloud.new(:client_id =>  ENV['SOUNDCLOUD_SERVER_APP_ID'] ,:access_token => ENV['SOUNDCLOUD_POPUPARCHIVE_USER_ACCESS_TOKEN'])
>>>>>>> Stashed changes
    station    = client.get('/resolve', :url => soundcloud_url, client_id: ENV['SOUNDCLOUD_SERVER_APP_ID'])
    tracks     = client.get("/users/#{station.id}/tracks")

    tracks.each do |track|
      if track.downloadable
        
        identifier = track.uri
        next if Item.where(identifier: identifier, collection_id: collection.id).exists?

        item = Item.new
        item.identifier   = identifier
        item.collection   = collection
        item.date_created = track.created_at
        item.title        = track.title
        item.description  = track.description

        audio = AudioFile.new
        audio.identifier      = track.download_url+"?client_id="+ENV['SOUNDCLOUD_SERVER_APP_ID']
        audio.remote_file_url = track.download_url+"?client_id="+ENV['SOUNDCLOUD_SERVER_APP_ID']
        item.audio_files << audio

        item.save!
      end
    end
  end

<<<<<<< Updated upstream
  def self.soundcloud_client
    Soundcloud.new({
      :client_id     => ENV['SOUNDCLOUD_SERVER_APP_ID'] ,
      :client_secret => ENV['SOUNDCLOUD_SERVER_APP_SECRET'],
      :redirect_uri  => ENV['SOUNDCLOUD_POP_REDIRECT_URL']
    })
  end

end
=======
end
>>>>>>> Stashed changes
