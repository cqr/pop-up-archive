class RemoveIsTranscriber < ActiveRecord::Migration
  def up
    remove_column :organizations, :is_transcriber
  end

  def down
    add_column :organizations, :is_transcriber, :boolean
  end
end
