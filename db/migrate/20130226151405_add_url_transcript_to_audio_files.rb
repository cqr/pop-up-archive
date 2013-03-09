class AddUrlTranscriptToAudioFiles < ActiveRecord::Migration
  def change
    add_column :audio_files, :url, :string
    add_column :audio_files, :transcript, :text
  end
end
