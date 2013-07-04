class CreateTranscripts < ActiveRecord::Migration
  def change
    create_table :transcripts do |t|
      t.references :audio_file
      t.string     :identifier
      t.string     :language
      t.integer    :start_time
      t.integer    :end_time
      t.timestamps
    end

    add_index :transcripts, [:audio_file_id, :identifier]
  end
end
