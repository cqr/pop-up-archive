class AddOriginalFileUrlToAudioFiles < ActiveRecord::Migration
  def change
    add_column :audio_files, :original_file_url, :string
  end
end
