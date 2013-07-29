class Tasks::CopyTask < Task

  attr_accessor :should_process
  @should_process = false

  state_machine :status do
    after_transition any => :complete do |task, transition|

      if task.owner
        result_path = URI.parse(task.extras['destination']).path
        storage_id = task.extras['storage_id'].to_i

        # set the file on the owner, and the storage as the upload_to
        task.owner.update_file!(File.basename(result_path), storage_id)
        task.should_process = true
      end

    end
  end

  after_commit :create_copy_job, :on => :create
  after_commit :start_transcribe, :on => :update

  def create_copy_job
    j = MediaMonsterClient.create_job do |job|
      job.job_type    = 'audio'
      job.original    = original
      job.retry_delay = 3600 # 1 hour
      job.retry_max   = 24 # try for a whole day
      job.priority    = 1

      job.add_task({
        task_type: 'copy',
        label:     self.id,
        result:    destination,
        call_back: call_back_url
      })
    end
  end

  def start_transcribe
    return unless should_process
    self.owner(true).transcribe_audio
    # self.owner(true).transcode_audio
    self.should_process = false
  end

  def call_back_url
    extras['call_back_url'] || owner.try(:call_back_url)
  end

  def destination
    extras['destination'] || owner.try(:destination, {
      storage: storage
    })
  end

  def original
    extras['original'] || owner.try(:original)
  end

end
