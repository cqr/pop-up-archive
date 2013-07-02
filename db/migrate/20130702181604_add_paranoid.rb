class AddParanoid < ActiveRecord::Migration
  def up
    add_column :items, :deleted_at, :time
    add_column :collections, :deleted_at, :time
    add_column :audio_files, :deleted_at, :time
  end

  def down
    remove_column :items, :deleted_at
    remove_column :collections, :deleted_at
    remove_column :audio_files, :deleted_at
  end
end
