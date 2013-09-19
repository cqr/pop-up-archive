class AddMeteredToAudioFiles < ActiveRecord::Migration
  def change
    add_column :audio_files, :metered, :boolean
  end
end
