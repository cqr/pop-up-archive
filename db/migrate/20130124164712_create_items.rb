class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title
      t.string :episode_title
      t.string :series_title
      t.text :description
      t.string :identifier
      t.date :date_broadcast
      t.date :date_created
      t.string :rights
      t.string :physical_format
      t.string :digital_format
      t.string :physical_location
      t.string :digital_location
      t.integer :duration
      t.string :music_sound_used
      t.string :date_peg
      t.text :notes
      t.text :transcription
      t.string :tags, array: true
      t.references :geolocation
      t.hstore :extra

      t.timestamps
    end
    add_index :items, :geolocation_id
  end
end
