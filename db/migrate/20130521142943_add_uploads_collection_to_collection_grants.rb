class AddUploadsCollectionToCollectionGrants < ActiveRecord::Migration
  def change
    add_column :collection_grants, :uploads_collection, :boolean, default: false
    CollectionGrant.update_all(uploads_collection: false)
  end
end
