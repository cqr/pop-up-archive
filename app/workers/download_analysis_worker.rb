# encoding: utf-8

require 'utils'

class DownloadAnalysisWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 25

  def perform(task_id)
    ActiveRecord::Base.connection_pool.with_connection do
      task       = Task.find(task_id)
      audio_file = task.owner
      connection = Fog::Storage.new(task.storage.credentials)
      uri        = URI.parse(task.destination)

      analysis   = download_file(connection, uri)    
      audio_file.item.process_analysis(analysis)
      true
    end
  end

  def download_file(connection, uri)
    Utils.download_private_file(connection, uri)
  end

end
