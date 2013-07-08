require 'uri'

class Tasks::AnalyzeTask < Task

  after_commit :create_analyze_job, :on => :create

  state_machine :status do
    after_transition any => :complete do |task, transition|

      if task.owner && !Rails.env.test?
        DownloadAnalysisWorker.perform_async(task.owner.id, task.destination)
      end

    end
  end

  def create_analyze_job
    j = MediaMonsterClient.create_job do |job|
      job.job_type    = 'text'
      job.original    = original
      job.retry_delay = 3600 # 1 hour
      job.retry_max   = 24 # try for a whole day
      job.priority    = 3

      job.add_task({
        task_type: 'analyze',
        label:     self.id,
        result:    destination,
        call_back: call_back_url
      })
    end
  end

  def call_back_url
    extras['call_back_url'] || owner.try(:call_back_url)
  end

  def destination
    extras['destination'] || owner.try(:destination, {
      :suffix  => '_analysis.json',
      :options => {:metadata=>{'x-archive-meta-mediatype'=>'data'}}
    })
  end

  def original
    extras['original'] || owner.try(:original)
  end

end
