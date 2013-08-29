class Tasks::OrderTranscriptTask < Task

  state_machine :status do
    after_transition any => :complete do |task, transition|

      if task.owner && !Rails.env.test?
        # process callback amara which will indicate that the transcript has been completed
        # may be callback from amara, or maybe from mobileworks...
      end

    end
  end

  after_commit :order_transcript, :on => :create

  def order_transcript
    # create the job at amara
    amara_video = amara_client.videos.create(amara_options)
    logger.debug("amara video created: #{amara_video.inspect}")

    # create task for mobile worker with this video url (and language specified?)
  end

  def amara_options
    lang = audio_file.item.language ? audio_file.item.language.split('-')[0].downcase : 'en' rescue 'en'
    team = ENV['AMARA_TEAM'] || 'prx-test-1'         # this should be an env constant perhaps?

    options = {
      # duration: audio_file.duration, # don't have this, could get from fixer analysis perhaps?
      team:      team,
      title:     audio_file.filename,
      video_url: audio_file.public_url,
      primary_audio_language_code: lang      
    }

    logger.debug "amara options: #{options.inspect}"

    options
  end

  def audio_file
    owner
  end

end
