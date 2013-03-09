class AddCopyMediaToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :copy_media, :boolean
  end
end
