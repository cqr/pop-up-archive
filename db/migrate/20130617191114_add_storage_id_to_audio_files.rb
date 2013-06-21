class AddStorageIdToAudioFiles < ActiveRecord::Migration
  def change
    add_column :audio_files, :storage_id, :integer
  end
end
