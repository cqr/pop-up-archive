# encoding: utf-8

require 'utils'

class CheckUrlWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 25

  def perform(task_id, version_name, url)
    result = nil
    ActiveRecord::Base.connection_pool.with_connection do
      task       = Task.find(task_id)
      audio_file = task.owner
      result     = url_exists?(url)
      task.mark_version_detected(version_name) if (audio_file && result)
    end
    result
  end

  def url_exists?(url)
    Utils.http_resource_exists?(url)
  end

end
