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

  def video_id
    self.extras['video_id']
  end

  def edit_video_transcript_url
    raise 'no url possible unless video id present' if video_id.blank?
    "http://www.amara.org/en/subtitles/editor/#{video_id}/en/"
  end

  def order_transcript
    # create the job at amara
    video = create_video
    # save the video_id, which is useful for crafting a url
    self.extras['video_id'] = video.id
    self.save!

    # create task for mobile worker with this video url (and language specified?)
    # first we probably need a gem for that...
  end

  def create_video
    response = amara_client.videos.create(amara_options)
    video = response.object
    logger.debug("amara video created: #{video.inspect}")
    video
  end

  def amara_options
    lang = audio_file.item.language ? audio_file.item.language.split('-')[0].downcase : 'en' rescue 'en'
    team = ENV['AMARA_TEAM_PRIVATE'] || 'prx-test-1' # this should be an env constant perhaps?

    options = {
      # duration: audio_file.duration, # don't have this, could get from fixer analysis perhaps?
      team:      team,
      title:     audio_file.filename,
      video_url: audio_file.public_url(extension: :ogg),
      primary_audio_language_code: lang
    }

    logger.debug "amara options: #{options.inspect}"

    options
  end

  def audio_file
    owner
  end

  def amara_client
    @client ||= Amara::Client.new(
      api_key:      ENV['AMARA_KEY'],
      api_username: ENV['AMARA_USERNAME'],
      endpoint:     ENV['AMARA_ENDPOINT']
    )
  end

end
