class FixVisibilityAndStorageConfiguration < ActiveRecord::Migration

  def up
    execute("UPDATE storage_configurations SET is_public = 't' where is_public is null AND provider = 'InternetArchive'")
    execute("UPDATE storage_configurations SET is_public = 'f' where is_public is null AND provider = 'AWS'")

    # set all the collections to have default and upload storage
    Collection.with_deleted.find_each{|c| c.set_storage; c.save!}

    # update the items to get rid of dupe storage config
    Item.with_deleted.find_each{|i|
      if i.storage_configuration && i.collection && (i.storage_configuration.key == i.collection.default_storage.key)
        i.storage_configuration.destroy
      end
    }

  end

  def down
  end

end
