# encoding: utf-8

require 'utils'

class CheckUrlWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 25

  def perform(task_id, version_name, url)
    ActiveRecord::Base.connection_pool.with_connection do
      task       = Task.find(task_id)
      audio_file = task.owner

      result     = Util.http_resource_exists?(url)
      task.version_detected(version_name) if af && result
    end
  end

end
