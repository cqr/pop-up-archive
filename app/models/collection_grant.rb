class CollectionGrant < ActiveRecord::Base
  belongs_to :collection
  belongs_to :user

  attr_accessible :collection, :collection_id, :user_id, :uploads_collection
end
