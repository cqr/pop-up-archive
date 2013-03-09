class AddStorageIdToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :default_storage_id, :integer
    add_column :items, :storage_id, :integer
  end
end
