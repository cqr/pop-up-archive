class CreateUploadsCollectionForExistingUsers < ActiveRecord::Migration
  def up
    User.find_each do |user|
      collection = Collection.create(title: "My Uploads", items_visible_by_default: false)
      CollectionGrant.create(collection_id: collection.id, uploads_collection: true, user_id: user.id)
    end
  end

  def down
    CollectionGrant.where(uploads_collection: true).find_each do |grant|
      grant.collection.destroy
      grant.destroy
    end
  end
end
