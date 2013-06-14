require "digest/sha1"

class Api::V1::AudioFilesController < Api::V1::BaseController

  expose :item
  expose :audio_files, ancestor: :item
  expose :audio_file

  def update
    if params[:task].present? && params[:task][:result_details][:status] == 'complete'
      audio_file.update_from_fixer(params[:task])
    else
      audio_file.update_attributes(params[:audio_file])
    end
    respond_with :api, audio_file.item, audio_file
  end

  def create
    if params[:file]
      audio_file.file = params[:file]
    end
    audio_file.save
    respond_with :api, audio_file.item, audio_file
  end

  def show
    redirect_to audio_file.url
  end

  def transcript_text
    response.headers['Content-Disposition'] = 'attachment'
    render text: audio_file.transcript_text, content_type: 'text/plain'
  end

  # these are for the request signing
  # really need to see if this is an AWS or IA item/collection
  # and depending on that, use a specific bucket/key
  include S3UploadHandler

  def bucket
    storage[:bucket]
  end

  def secret
    storage[:secret]
  end

  def storage
    # could also look up for the item...hmm - AK
    StorageConfiguration.default_storage(false)
  end

  def init_signature
    key           = params[:key]
    filesize      = params[:filesize].to_i
    filename      = params[:filename]
    last_modified = params[:last_modified]

    if task = audio_file.tasks.incomplete.where(name: 'upload', identifier: identifier).first
      result = task.extras
    else
      extras = {
        user_id:         current_user.id,
        filename:        filename,
        filesize:        filesize,
        last_modified:   last_modified,
        chunks_uploaded: [].to_csv,
        key:             key
      }
      task = audio_file.tasks.create!(name: 'upload', identifier: identifier, extras: extras, status: Task::CREATED)
      result = signature_hash(:init)
    end

    render json: result
  end

  def all_signatures
    task = audio_file.tasks.incomplete.where(name: 'upload', identifier: identifier).first
    task.extras['num_chunks'] = params['num_chunks'].to_i
    task.extras['upload_id'] = params['upload_id']
    task.status = Task::WORKING
    task.save!

    render json: all_signatures_hash
  end

  def chunk_loaded
    result = {}

    if task = audio_file.tasks.incomplete.where(name: 'upload', identifier: identifier).first
      chunk = params[:chunk].to_i
      chunks_uploaded = (task.extras['chunks_uploaded'].parse_csv.map(&:to_i) << chunk).sort.uniq
      task.extras['chunks_uploaded'] = chunks_uploaded.to_csv
      task.status = Task::COMPLETE if (task.extras['num_chunks'].to_i <= chunks_uploaded.size)
      task.save!

      result = task.extras
    end

    render json: result
  end

  protected

  def identifier(options=nil)
    o = options || {
      user_id:       current_user.id,
      filename:      params[:filename],
      filesize:      params[:filesize],
      last_modified: params[:last_modified]
    }
    Digest::SHA1.hexdigest("u:#{o[:user_id]};n:#{o[:filename]};s:#{o[:filesize]};m:#{o[:last_modified]}")
  end

end
