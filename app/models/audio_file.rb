# encoding: utf-8

class AudioFile < ActiveRecord::Base
  belongs_to :item
  belongs_to :instance
  attr_accessible :file
  mount_uploader :file, ::AudioFileUploader
  after_commit :process_file, on: :create
  attr_accessor :should_trigger_fixer_copy

  delegate :collection_title, to: :item

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

  def storage
    item.try(:storage) || StorageConfiguration.default_storage
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
        # self.transcript = Utils.download_file
        DownloadTranscriptWorker.perform_async(self.id, params[:result]) unless Rails.env.test?
      else
        nil
      end
      save
    end
  end

  def url_with_credentials
    return url unless self.file.url
    uri = URI.parse(self.file.url)
    uri.user = storage.key
    uri.password = storage.secret
    uri.to_s
  end

  # private

  def process_file
    logger.debug "fixer_copy start: collection: #{self.item.try(:collection).inspect}, should_trigger_fixer_copy: #{should_trigger_fixer_copy}"

    if self.item.collection.copy_media && should_trigger_fixer_copy
      MediaMonsterClient.create_job do |job|
        job.original = original_file_url
        job.job_type = "audio"
        job.add_task task_type: 'copy', result: destination, call_back: audio_file_callback_url
      end
    end

    self.should_trigger_fixer_copy = false

    if self.transcript.blank?
      MediaMonsterClient.create_job do |job|
        job.job_type = 'audio'
        job.priority = 1
        job.original = url_with_credentials
        job.add_sequence do |seq|
          seq.add_task task_type: 'cut', options: {length: 60, fade: 0}
          seq.add_task task_type: 'transcribe', result: "#{destination}_ts_start.json", call_back: audio_file_callback_url, label:"ts_start"
        end
      end

      MediaMonsterClient.create_job do |job|
        job.job_type = 'audio'
        job.priority = 1
        job.original = url_with_credentials
        job.add_task task_type: 'transcribe', result: "#{destination}_ts_all.json", call_back: audio_file_callback_url, label:'ts_all'
      end
    end

  end

  def analyze_transcript
    MediaMonsterClient.create_job do |job|
      job.job_type = 'text'
      job.priority = 1
      job.original = transcript_text_url
      job.add_task task_type: 'analyze', result: "#{destination}_analysis.json", call_back: audio_file_callback_url, label:'analyze'
    end
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

  def destination
    scheme = case file.fog_credentials[:provider].downcase
    when 'aws' then 's3'
    when 'internetarchive' then 'ia'
    end

    host = file.fog_directory

    (URI::Generic.build scheme: scheme, host: host, path: "/#{file_path}").to_s
  end
end
