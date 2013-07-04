# encoding: utf-8

require 'utils'

class DownloadTranscriptWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 25

  def perform(audio_file_id, transcript_url)
    ActiveRecord::Base.connection_pool.with_connection do
      audio_file = AudioFile.find(audio_file_id)
      connection = Fog::Storage.new(audio_file.file.fog_credentials)
      uri = URI.parse(transcript_url)

      audio_file.process_transcript(Utils.download_private_file(connection, uri))
      
      audio_file.analyze_transcript
    end
  end

end
