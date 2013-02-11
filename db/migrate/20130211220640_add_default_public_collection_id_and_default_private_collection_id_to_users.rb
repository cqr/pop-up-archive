class AddDefaultPublicCollectionIdAndDefaultPrivateCollectionIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :default_public_collection_id, :integer
    add_column :users, :default_private_collection_id, :integer
  end
end
