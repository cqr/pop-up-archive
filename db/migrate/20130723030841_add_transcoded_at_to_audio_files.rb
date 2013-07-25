class AddTranscodedAtToAudioFiles < ActiveRecord::Migration
  def change
    add_column :audio_files, :transcoded_at, :time
  end
end
