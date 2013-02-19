class CreateAudioFiles < ActiveRecord::Migration
  def change
    create_table :audio_files do |t|
      t.references :item
      t.string :file

      t.timestamps
    end
    add_index :audio_files, :item_id
  end
end
