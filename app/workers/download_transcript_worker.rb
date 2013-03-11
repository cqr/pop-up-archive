# encoding: utf-8

require 'utils'

class DownloadTranscriptWorker
  include Sidekiq::Worker

  def perform(audio_file_id, transcript_url)
    audio_file = AudioFile.find(audio_file_id)    
    connection = Fog::Storage.new(audio_file.file.fog_credentials)
    uri = URI.parse(transcript_url)
    audio_file.transcript = Utils.download_private_file(connection, uri)
    audio_file.save!
    audio_file.item.update_transcription!
  end

end
