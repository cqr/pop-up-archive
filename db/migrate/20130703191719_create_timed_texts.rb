class CreateTimedTexts < ActiveRecord::Migration
  def change
    create_table :timed_texts do |t|
      t.references :transcript
      t.integer    :start_time
      t.integer    :end_time
      t.text       :text
      t.decimal    :confidence
      t.timestamps
    end

    add_index :timed_texts, [:start_time, :transcript_id]
  end
end
