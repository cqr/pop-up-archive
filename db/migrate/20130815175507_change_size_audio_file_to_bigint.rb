class ChangeSizeAudioFileToBigint < ActiveRecord::Migration
  def up
  	change_column :audio_files, :size, :bigint
	end

  def down
		change_column :audio_files, :size, :int
  end
end
