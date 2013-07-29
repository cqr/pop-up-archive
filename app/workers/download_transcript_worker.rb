# encoding: utf-8

require 'utils'

class DownloadTranscriptWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 25

  def perform(task_id)
    ActiveRecord::Base.connection_pool.with_connection do
      task       = Task.find(task_id)
      audio_file = task.owner
      connection = Fog::Storage.new(task.storage.credentials)
      uri        = URI.parse(task.destination)

      transcript = download_file(connection, uri)
      new_trans  = audio_file.process_transcript(transcript)

      # if new transcript resulted, then call analyze
      audio_file.analyze_transcript if new_trans
      true
    end
  end

  def download_file(connection, uri)
    Utils.download_private_file(connection, uri)
  end

end
