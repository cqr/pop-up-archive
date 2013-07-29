class Tasks::DetectDerivativesTask < Task

  state_machine :status do
    after_transition any => :complete do |task, transition|

      if task.audio_file
        # mark the audio_file as having processing complete?
        audio_file.update_attribute(:transcoded_at, DateTime.now)
      end

    end
  end

  after_commit :start_detective, on: :create
  after_commit :check_complete, on: :update

  def check_complete
    return if complete?
    any_nil = extras.urls.keys.detect{|version| version_info(version)[:detected_at].nil?}
    self.finish! if !any_nil
  end
  
  def audio_file
    self.owner
  end

  def version_detected(version)
    version_info(version)[:detected_at] = DateTime.now unless version_info(version)[:detected_at]
    self.save!
  end

  def version_info(version)
    version_info(version)
  end

  def start_detective
    extras.urls.each do |version, info|
      CheckUrlWorker.perform_async(id, version, v[:url])
    end
  end

end
