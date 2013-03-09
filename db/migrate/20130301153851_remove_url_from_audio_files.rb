class RemoveUrlFromAudioFiles < ActiveRecord::Migration
  def up
    remove_column :audio_files, :url
  end

  def down
    add_column :audio_files, :url, :string
  end
end
