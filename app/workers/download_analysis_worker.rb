# encoding: utf-8

require 'utils'

class DownloadAnalysisWorker
  include Sidekiq::Worker

  def perform(audio_file_id, analysis_url)
    audio_file = AudioFile.find(audio_file_id)
    file = audio_file.file
    connection = Fog::Storage.new(file.fog_credentials)
    uri = URI.parse(transcript_url)
    analysis = Utils.download_private_file(connection, uri)
    item.process_analysis(analysis)
  end

end
