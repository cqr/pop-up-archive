class AddToAudioFile < ActiveRecord::Migration
  def change
    add_column :audio_files, :format, :string
    add_column :audio_files, :size, :integer
  end
end
