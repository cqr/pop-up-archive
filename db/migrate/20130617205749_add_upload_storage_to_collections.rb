class AddUploadStorageToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :upload_storage_id, :integer
  end
end
