class Tasks::TranscodeTask < Task

  state_machine :status do
    after_transition any => :complete do |task, transition|

      if task.audio_file
        # mark the audio_file as having processing complete?
        task.audio_file.update_attribute(:transcoded_at, DateTime.now)
      end

    end
  end

  after_commit :create_transcode_job, :on => :create

  before_save do
    self.extras['formats'] ||= default_formats
    self.serialize_extra('formats')
  end

  def audio_file
    self.owner
  end

  def formats
    deserialize_extra('formats', {})
  end

  def default_formats
    AudioFileUploader.version_formats
  end

  def call_back_url
    extras['call_back_url'] || owner.try(:call_back_url)
  end

  def destination(version)
    extras['destination'] || owner.try(:destination, {
      storage: storage,
      version: version
    })
  end

  def original
    extras['original'] || owner.try(:destination)
  end

  def add_transcode_task(job, label, options)
    task_hash = {
      :task_type => 'transcode',
      :result    => destination(options['suffix'] || options['format']),
      :call_back => call_back_url,
      :options   => options,
      :label     => label
    }
    job.add_task task_hash
  end

  def create_transcode_job
    j = create_job do |job|
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

  def create_job
    job_id = nil

    begin
      new_job = MediaMonsterClient.create_job do |job|
        yield job
      end
      
      logger.debug("create_job: created: #{new_job.inspect}")
      job_id = new_job.id

    rescue Object=>exception
      logger.error "create_job: error: #{exception.class.name}: #{exception.message}\n\t#{exception.backtrace.join("\n\t")}"
      job_id = 1
    end
    job_id
  end

end
