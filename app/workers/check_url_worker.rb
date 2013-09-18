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

      if (audio_file && result)
        task.mark_version_detected(version_name)
      else
        raise "URL not found yet, try again: #{url}"
      end

    end
    result
  end

  def url_exists?(url)
    Utils.http_resource_exists?(url)
  end

end
