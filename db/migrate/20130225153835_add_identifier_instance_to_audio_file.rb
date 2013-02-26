class AddIdentifierInstanceToAudioFile < ActiveRecord::Migration
  def change
    add_column :audio_files, :identifier, :string
    add_column :audio_files, :instance_id, :integer
  end
end
