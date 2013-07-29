class Tasks::TranscodeTask < Task

  state_machine :status do
    after_transition any => :complete do |task, transition|

      if task.owner && !Rails.env.test?

      end

    end
  end

  after_commit :create_transcode_job, :on => :create

  def create_transcode_job
    j = MediaMonsterClient.create_job do |job|
      job.job_type = 'audio'
      job.original = original
      job.priority = 4
      job.retry_delay = 3600 # 1 hour
      job.retry_max = 24 # try for a whole day
      formats.each do |label, format|
        add_transcode_task job, label, format
      end
    end

  end

  def add_transcode_task(job, label, options)
    task_hash = {
      :task_type => 'transcode',
      :result    => destination(options[:suffix] || options[:format]),
      :call_back => call_back_url,
      :options   => options,
      :label     => label
    }
    job.add_task task_hash
  end

  def formats
    extras['formats'] || default_formats
  end

  def start_only?
    !!extras['start_only']
  end

  def call_back_url
    extras['call_back_url'] || owner.try(:call_back_url)
  end

  def destination
    suffix = start_only? ? '_ts_start.json' : '_ts_all.json'
    extras['destination'] || owner.try(:destination, {
      storage: storage,
      suffix: suffix
    })
  end

  def original
    extras['original'] || owner.try(:original)
  end

end
