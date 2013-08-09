# encoding: utf-8

class FinishTaskWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 25

  def perform(task_id)
    ActiveRecord::Base.connection_pool.with_connection do
      task = Task.find(task_id)
      task.finish!
      true
    end
  end

end
