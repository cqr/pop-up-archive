require "digest/sha1"

class Tasks::UploadTask < Task

  state_machine :status do
    after_transition any => :complete do |task, transition|

      if task.owner.nil?
        task.extras['debug_message'] = "No owner defined: #{task.id}: #{task.owner_type}, #{task.owner_id}"
      else
        # set the file on the owner, and the storage as the upload_to
        file_name = File.basename(task.extras['key'])
        upload_id = task.owner.upload_to.id

        task.owner.update_file!(file_name, upload_id)

        # now copy it to the right place if it needs to be (e.g. s3 -> ia)
        task.owner.copy_to_item_storage
      end

    end
  end

  before_validation(on: :create) do
    self.extras = {} unless extras
    self.extras['chunks_uploaded'] = [].to_csv unless self.extras.key?(:chunks_uploaded)
    self.identifier = Tasks::UploadTask.make_identifier(extras) unless identifier
  end

  after_commit do
    return unless ((num_chunks > 0) && (num_chunks <= chunks_uploaded.size) && !complete?)
    self.finish!
  end

  def num_chunks
    extras['num_chunks'].to_i
  end

  def add_chunk!(chunk)
    self.chunks_uploaded = (chunks_uploaded << chunk.to_i).sort.uniq
    save!
  end

  def chunks_uploaded
    (extras['chunks_uploaded'] || [].to_csv).parse_csv.map(&:to_i)
  end

  def chunks_uploaded=(chunks_array)
    self.extras ||= {}
    self.extras['chunks_uploaded'] = chunks_array.to_csv
  end

  def self.make_identifier(o=nil)
    raise 'you must pass in options to make an identifier' unless o
    Digest::SHA1.hexdigest("u:#{o[:user_id]};n:#{o[:filename]};s:#{o[:filesize]};m:#{o[:last_modified]}")
  end

end
