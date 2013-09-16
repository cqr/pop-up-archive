class AddDurationToAudioFiles < ActiveRecord::Migration
  def change
    add_column :audio_files, :duration, :integer
  end
end
