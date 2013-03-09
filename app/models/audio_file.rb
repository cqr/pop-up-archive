# encoding: utf-8

class AudioFile < ActiveRecord::Base
  belongs_to :item
  belongs_to :instance
  attr_accessible :file
  mount_uploader :file, ::AudioFileUploader
  after_commit :process_file
  attr_accessor :should_trigger_fixer_copy

  delegate :collection_title, to: :item

  def remote_file_url=(url)
    self.original_file_url = url
    self.should_trigger_fixer_copy = !!url
    logger.debug "remote_file_url: #{self.original_file_url}"
  end

  def collection
    instance.try(:item).try(:collection) || item.try(:collection)
  end

  def storage
    self.try(:item).try(:storage)
  end

  def url
    self.file.url || original_file_url
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

  private

  def process_file
    logger.debug "fixer_copy start: collection: #{self.item.try(:collection).inspect}, should_trigger_fixer_copy: #{should_trigger_fixer_copy}"
    return unless should_trigger_fixer_copy

    if self.item.collection.copy_media
      MediaMonsterClient.create_job do |job|
        job.original = original_file_url
        job.job_type = "audio"
        job.add_task task_type: 'copy', result: destination, call_back: audio_file_callback_url
      end
    end

    if self.transcript.blank?
      # get 30 sec transcript first
      MediaMonsterClient.create_job do |job|
        job.job_type = 'audio'
        job.priority = 1
        job.original = self.url
        job.add_sequence do |seq|
          seq.add_task task_type: 'cut', options: {length: 30, fade: 0}
          seq.add_task task_type: 'transcribe', result: "#{destination}_ts30.json", call_back: audio_file_callback_url, label:'ts30'
        end
      end

      MediaMonsterClient.create_job do |job|
        job.job_type = 'audio'
        job.priority = 1
        job.original = self.url
        job.add_task task_type: 'transcribe', result: "#{destination}_ts.json", call_back: audio_file_callback_url, label:'ts'
      end
    end

    self.should_trigger_fixer_copy = false

  end

  def file_path
    file.store_path(File.basename(original_file_url))
  end

  def audio_file_callback_url
    Rails.application.routes.url_helpers.api_item_audio_file_url(item_id, id)
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
