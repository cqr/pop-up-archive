# encoding: utf-8

require 'utils'

class DownloadAnalysisWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 25

  def perform(audio_file_id, analysis_url)
    ActiveRecord::Base.connection_pool.with_connection do
      audio_file = AudioFile.find(audio_file_id)
      connection = Fog::Storage.new(audio_file.file.fog_credentials)
      uri = URI.parse(analysis_url)
      analysis = Utils.download_private_file(connection, uri)    
      audio_file.item.process_analysis(analysis)
      true
    end
  end

end
