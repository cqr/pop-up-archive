class AudioFile < ActiveRecord::Base
  belongs_to :item
  attr_accessible :file
  mount_uploader :file, ::AudioFileUploader
  after_commit :fixer_copy, if: :should_trigger_fixer_copy
  attr_accessor :should_trigger_fixer_copy

  delegate :collection_title, to: :item

  def remote_file_url=(url)
    self.should_trigger_fixer_copy = !!url
    self.original_file_url = url
  end

  def update_from_fixer(params)
    if params['result_details']['status'] == 'complete'
      case params['task_type']
      when 'copy' then
        file_will_change!
        raw_write_attribute :file, File.basename(params[:result])
      else
        nil
      end
      save
    end
  end

  private

  def fixer_copy
    MediaMonsterClient.create_job do |job|
      job.original = original_file_url
      job.job_type = "audio"
      job.add_task task_type: 'copy', result: destination, call_back: audio_file_copied_callback_url
    end
    should_trigger_fixer_copy = false
  end

  def file_path
    file.store_path(File.basename(original_file_url))
  end

  def audio_file_copied_callback_url
    Rails.application.routes.url_helpers.api_item_audio_file_url item_id, id
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
