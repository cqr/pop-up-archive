# encoding: utf-8

class AudioFile < ActiveRecord::Base
  belongs_to :item
  belongs_to :instance
  has_many :tasks, as: :owner

  belongs_to :storage_configuration, class_name: "StorageConfiguration", foreign_key: :storage_id

  attr_accessible :file

  mount_uploader :file, ::AudioFileUploader

  after_commit :process_file, on: :create

  attr_accessor :should_trigger_fixer_copy

  delegate :collection_title, to: :item

  def multipart_upload_complete(task=nil)
    # this works for the case when it is a private file, need to do a copy when it is public
    if task ||= tasks.complete.where(name: 'upload').last
      write_attribute(:file, File.basename(task.extras['key']))
      self.storage_configuration = upload_to
      save!
    end
  end

  def copy_storage
    # if the storage is not the same as the item, we need to copy/move it over
    if storage != item.storage

      # see if there is already a copy task in progress

      if tasks = tasks.where(name: 'copy')
        tasks.each{|t| t.options['destination']}
      end

    end
  end


  def transcript_text
    return '' unless transcript
    trans_json = JSON.parse(transcript)
    trans_json.collect{|i| i['text']}.join(' ')
  end

  def remote_file_url=(url)
    self.original_file_url = url
    self.should_trigger_fixer_copy = !!url
    logger.debug "remote_file_url: #{self.original_file_url}"
  end

  def collection
    instance.try(:item).try(:collection) || item.try(:collection)
  end

  def upload_to
    storage.direct_upload? ? storage : item.upload_to
  end

  def storage
    self.storage_configuration || self.item.storage
  end

  def url
    if file.url
      self.file.url
    else
      original_file_url
    end
  end

  def filename
    return '' unless self.file.path
    File.basename(self.file.path)
  end

  def update_from_fixer(params)
    if params['result_details']['status'] == 'complete'
      case params['task_type']
      when 'copy' then
        file_will_change!
        raw_write_attribute :file, File.basename(params[:result])
      when 'transcribe' then
        # don't overwrite with partial
        # only add transcript if there is none, or it is the full tranascript
        if params['label'] == 'ts_all' || self.transcript.blank?
          DownloadTranscriptWorker.perform_async(self.id, params[:result]) unless Rails.env.test?
        end
      when 'analyze'
        DownloadAnalysisWorker.perform_async(self.id, params[:result]) unless Rails.env.test?
      else
        nil
      end
      save
    end
  end

  # private

  def process_file
    logger.debug "fixer_copy start: collection: #{self.item.try(:collection).inspect}, should_trigger_fixer_copy: #{should_trigger_fixer_copy}"

    if self.item.collection.copy_media && should_trigger_fixer_copy
      MediaMonsterClient.create_job do |job|
        job.original = process_audio_url
        job.job_type = "audio"
        job.retry_delay = 3600 # 1 hour
        job.retry_max = 24 # try for a whole day
        job.add_task task_type: 'copy', result: destination, call_back: audio_file_callback_url
      end
    end
    self.should_trigger_fixer_copy = false

    if self.transcript.blank?
      MediaMonsterClient.create_job do |job|
        job.job_type = 'audio'
        job.priority = 1
        job.original = process_audio_url
        job.retry_delay = 3600 # 1 hour
        job.retry_max = 24 # try for a whole day
        job.add_sequence do |seq|
          seq.add_task task_type: 'cut', options: {length: 60, fade: 0}
          seq.add_task task_type: 'transcribe', result: destination('_ts_start.json'), call_back: audio_file_callback_url, label:"ts_start"
        end
      end

      MediaMonsterClient.create_job do |job|
        job.job_type = 'audio'
        job.priority = 2
        job.retry_delay = 3600 # 1 hour
        job.retry_max = 24 # try for a whole day
        job.original = process_audio_url
        job.add_task task_type: 'transcribe', result: destination('_ts_all.json'), call_back: audio_file_callback_url, label:'ts_all'
      end
    end

  end

  def analyze_transcript
    MediaMonsterClient.create_job do |job|
      job.job_type = 'text'
      job.priority = 1
      job.retry_delay = 3600 # 1 hour
      job.retry_max = 24 # try for a whole day
      job.original = transcript_text_url
      job.add_task task_type: 'analyze', result: destination('_analysis.json'), call_back: audio_file_callback_url, label:'analyze', options: transcribe_options
    end
  end

  def transcribe_options
    {
      language:         'en-US',
      chunk_duration:   5,
      overlap:          1,
      max_results:      1,
      profanity_filter: true
    }
  end

  def file_path
    file.store_path(File.basename(original_file_url || self.file.path))
  end

  def audio_file_callback_url
    Rails.application.routes.url_helpers.api_item_audio_file_url(item_id, id)    
  end

  def transcript_text_url
    Rails.application.routes.url_helpers.api_item_audio_file_transcript_text_url(item_id, id)
  end

  def process_audio_url
    if file.url
      if file.fog_credentials[:provider].downcase == 'aws'
        destination
      else
        file.url
      end
    else
      original_file_url
    end
  end

  def destination(suffix='')
    scheme = case file.fog_credentials[:provider].downcase
    when 'aws' then 's3'
    when 'internetarchive' then 'ia'
    end

    host = file.fog_directory

    logger.debug("audio_file: destination: scheme: #{scheme}, host:#{host}, path: /#{file_path}")
    uri = URI::Generic.build scheme: scheme, host: host, path: "/#{file_path}"
    if scheme == 'ia'
      uri.user = storage.key
      uri.password = storage.secret
    end
    uri.to_s + suffix
  end

end
