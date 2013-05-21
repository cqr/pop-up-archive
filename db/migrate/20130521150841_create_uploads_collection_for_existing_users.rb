class CreateUploadsCollectionForExistingUsers < ActiveRecord::Migration
  def up
    User.find_each do |user|
      user.save
    end
  end

  def down
    CollectionGrant.where(uploads_collection: true).find_each do |grant|
      grant.collection.destroy
      grant.destroy
    end
  end
end
