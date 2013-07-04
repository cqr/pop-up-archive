# encoding: utf-8
require "digest/sha1"

class AudioFile < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :item, :with_deleted => true
  belongs_to :instance
  has_many :tasks, as: :owner
  has_many :transcripts

  belongs_to :storage_configuration, class_name: "StorageConfiguration", foreign_key: :storage_id

  attr_accessible :file

  mount_uploader :file, ::AudioFileUploader

  after_commit :process_file, on: :create

  attr_accessor :should_trigger_fixer_copy

  delegate :collection_title, to: :item

  def collection
    instance.try(:item).try(:collection) || item.try(:collection)
  end

  def filename
    file.try(:path) ? File.basename(file.path) : ''
  end

  def url
    file.try(:url) ? file.url : original_file_url
  end

  def storage
    self.storage_configuration || self.item.storage
  end

  def store_dir(stor=storage)
    stor.use_folders? ? "#{item.try(:token)}/#{path}" : nil
  end

  def remote_file_url=(url)
    self.original_file_url = url
    self.should_trigger_fixer_copy = !!url
    logger.debug "remote_file_url: #{self.original_file_url}"
  end

  def upload_to
    storage.direct_upload? ? storage : item.upload_to
  end

  def update_file!(name, sid)
    sid = sid.to_i
    file_will_change!
    raw_write_attribute(:file, name)
    if (sid > 0) && (self.storage.id != sid)
      # see if the item is right
      if item.storage.id == sid
        self.storage_id = nil
        self.storage_configuration = nil
      else
        self.storage_id = sid
        self.storage_configuration = StorageConfiguration.find(sid)
      end
    end

    save!
  end

  def update_from_fixer(params)

    # get the status of the fixer task
    result = params['result_details']['status']

    # get the task id from the label
    task = tasks.where(id: params['label']).last
    return unless task

    logger.debug "update_from_fixer: task #{params['label']} is #{result}"

    # update with the job id
    if !task.extras['job_id'] && params['job'] && params['job']['id']
      task.extras['job_id'] = params['job']['id']
      task.save!
    end

    case result
    when 'created'    then logger.debug "task #{params['label']} created"
    when 'processing' then task.begin!
    when 'complete'   then task.finish!
    when 'error'      then task.failure!
    else nil
    end

  rescue Exception => e
    logger.error e.message
    logger.error e.backtrace.join("\n")
  end

  def process_file
    # don't process file if no file to process yet (s3 upload)
    return if file.blank? && original_file_url.blank?

    copy_original
    
    transcribe_audio

  rescue Exception => e
    logger.error e.message
    logger.error e.backtrace.join("\n")
  end

  def copy_original
    return false unless (should_trigger_fixer_copy && item.collection.copy_media && original_file_url)
    create_copy_task(original_file_url, destination, storage)
    self.should_trigger_fixer_copy = false
  end

  def copy_to_item_storage
    return false unless (storage != item.storage)
    create_copy_task(destination, destination(storage: item.storage), item.storage)
  end

  def create_copy_task(orig, dest, stor=storage)
    # see if there is already a copy task in progress
    if task = tasks.incomplete.copy.where(identifier: dest).last
      logger.debug "copy task #{task.id} already exists for audio_file #{self.id}"
    else
      task = Tasks::CopyTask.new(extras: {
        original:    orig,
        destination: dest,
        storage_id:  stor.id
      })
      self.tasks << task
    end
    task
  end

  def transcribe_audio
    # see if there is a non-failed task for this audio file
    if task = tasks.transcribe.without_status(:failed).where(identifier: 'ts_start').last
      logger.debug "transcribe task ts_start #{task.id} already exists for audio_file #{self.id}"
    else
      self.tasks << Tasks::TranscribeTask.new(identifier: 'ts_start', extras: { start_only: true, original: process_audio_url })
    end

    if task = tasks.transcribe.without_status(:failed).where(identifier: 'ts_all').last
      logger.debug "transcribe task ts_all #{task.id} already exists for audio_file #{self.id}"
    else
      self.tasks << Tasks::TranscribeTask.new(identifier: 'ts_all', extras: { original: process_audio_url })
    end
  end

  def transcript_array
    array = timed_transcript_array
    array = JSON.parse(transcript) if (array.blank? && !transcript.blank?)
    array || []
  end

  def transcript_text
    txt = timed_transcript_text 
    txt = JSON.parse(transcript).collect{|i| i['text']}.join("\n") if (txt.blank? && !transcript.blank?)
    txt || ''
  end

  def timed_transcript_text(language='en-US')
    (timed_transcript(language).try(:timed_texts) || []).collect{|tt| tt.text}.join("\n")
  end

  def timed_transcript_array(language='en-US')
    (timed_transcript(language).try(:timed_texts) || []).collect{|tt| tt.as_json(only: [:id, :start_time, :end_time, :text])}
  end

  def timed_transcript(language='en-US')
    transcripts.where(language: language).order('end_time DESC').first
  end

  def process_transcript(json)
    return if json.blank?

    identifier = Digest::MD5.hexdigest(json)

    if trans = transcripts.where(identifier: identifier).first
      logger.debug "transcript #{trans.id} already exists for this json: #{json[0,50]}"
    else
      trans_json = JSON.parse(json) if json.is_a?(String)
      trans = transcripts.build(language: 'en-US', identifier: identifier, start_time: 0, end_time: 0)
      trans_json.each do |row|
        tt = trans.timed_texts.build({
          start_time: row['start_time'],
          end_time:   row['end_time'],
          confidence: row['confidence'],
          text:       row['text']
        })
        trans.end_time = tt.end_time if tt.end_time > trans.end_time
        trans.start_time = tt.start_time if tt.start_time < trans.start_time
      end
      trans.save!

      # delete trans which cover less time
      partials_to_delete = transcripts.where("language = 'en-US' AND end_time < ?", trans.end_time)
      partials_to_delete.each{|t| t.destroy}
    end
    trans
  end

  def analyze_transcript
    # TODO add dupe check and force
    self.tasks << Tasks::AnalyzeTask.new(extras: { original: transcript_text_url })
  end

  def transcript_text_url
    Rails.application.routes.url_helpers.api_item_audio_file_transcript_text_url(item_id, id)
  end

  def call_back_url
    Rails.application.routes.url_helpers.api_item_audio_file_url(item_id, id)
  end

  def process_audio_url
    if !file.blank?
      if file.fog_credentials[:provider].downcase == 'aws'
        destination
      else
        file.url
      end
    else
      original_file_url
    end
  end

  def destination_options(options={})
    stor = options[:storage] || storage
    dest_opts = options[:options] || {}
    da = stor.attributes || {}
    da.reverse_merge!(dest_opts)

    if stor.provider == 'InternetArchive'
      if Rails.env.production?
        da[:collections] = [] unless da.has_key?(:collections)
        da[:collections] << 'popuparchive' unless da[:collections].include?('popuparchive')
      end

      default_subject = item.try(:collection).try(:title)
      da[:subjects] = [] unless da.has_key?(:subjects)
      da[:subjects] << default_subject unless da[:subjects].include?(default_subject)

      da[:metadata] = {} unless da.has_key?(:metadata)
      da[:metadata]['x-archive-meta-title'] ||= item.try(:title)
      da[:metadata]['x-archive-meta-mediatype'] ||= 'audio'
    end

    da
  end

  def destination_path(options={})
    stor = options[:storage] || storage
    File.join([ "/", (store_dir(stor) || ''), File.basename(original_file_url || self.filename)])
  end

  def destination_directory(options={})
    stor = options[:storage] || storage
    stor.use_folders? ? stor.bucket : item.token
  end

  def destination(options={})
    stor = options[:storage] || storage
    suffix = options[:suffix] || ''
  
    scheme = case stor.provider.downcase
    when 'aws' then 's3'
    when 'internetarchive' then 'ia'
    else 's3'
    end

    opts = destination_options(options)
    query = opts.inject({}){|h, p| h["x-fixer-#{p[0]}"] = p[1]; h}.to_query if !opts.blank?

    host = destination_directory(options)
    path = destination_path(options) + suffix

    # logger.debug("audio_file: destination: scheme: #{scheme}, host:#{host}, path:#{path}")
    uri = URI::Generic.build scheme: scheme, host: host, path: path, query: query
    if scheme == 'ia'
      uri.user = stor.key
      uri.password = stor.secret
    end
    uri.to_s
  end

end
