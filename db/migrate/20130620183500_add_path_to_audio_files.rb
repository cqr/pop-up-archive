class AddPathToAudioFiles < ActiveRecord::Migration
  def up
    add_column :audio_files, :path, :string
    execute "UPDATE audio_files SET path = 'audio_files'"
  end

  def down
    remove_column :audio_files, :path
  end
end
