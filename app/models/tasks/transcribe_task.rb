class Tasks::TranscribeTask < Task

  state_machine :status do
    after_transition any => :complete do |task, transition|

      # only add transcript if there is none, or it is the full tranascript; don't overwrite all with start
      if task.owner && (task.owner.transcript.blank? || !task.start_only?) && !Rails.env.test?
        DownloadTranscriptWorker.perform_async(task.owner.id, task.destination)
      end

    end
  end

  after_commit :create_transcribe_job, :on => :create

  def create_transcribe_job
    if start_only?
      j = MediaMonsterClient.create_job do |job|
        job.job_type    = 'audio'
        job.original    = original
        job.priority    = 1
        job.retry_delay = 3600 # 1 hour
        job.retry_max   = 24 # try for a whole day
        job.add_sequence do |seq|
          seq.add_task task_type: 'cut', options: {length: 60, fade: 0}
          seq.add_task task_type: 'transcribe', result: destination, call_back: call_back_url, label: self.id
        end
      end
    else
      j = MediaMonsterClient.create_job do |job|
        job.job_type = 'audio'
        job.original = original
        job.priority = 2
        job.retry_delay = 3600 # 1 hour
        job.retry_max = 24 # try for a whole day
        job.add_task task_type: 'transcribe', result: destination, call_back: call_back_url, label: self.id
      end
    end
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
      :suffix  => suffix,
      :options => {:metadata=>{'x-archive-meta-mediatype'=>'data'}}
    })
  end

  def original
    extras['original'] || owner.try(:original)
  end

end
