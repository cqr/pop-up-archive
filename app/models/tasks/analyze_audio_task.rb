class Tasks::AnalyzeAudioTask < Task

  after_commit :create_analyze_job, :on => :create

  state_machine :status do
    after_transition any => :complete do |task, transition|
      if task.owner && !Rails.env.test?
        task.owner.complete_analysis(task.params[:result_details][:info]) if task.owner.respond_to? :complete_analysis
      end
    end
  end

  def create_analyze_job
    j = MediaMonsterClient.create_job do |job|
      job.job_type    = 'audio'
      job.original    = original
      job.retry_delay = 3600 # 1 hour
      job.retry_max   = 24 # try for a whole day
      job.priority    = 3

      job.add_task({
        task_type: 'analyze',
        label:     self.id,
        call_back: call_back_url
      })
    end
  end

  def call_back_url
    extras['call_back_url'] || owner.try(:call_back_url)
  end

  def original
    extras['original'] || owner.try(:original)
  end

end