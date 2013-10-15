class CollectionGrant < ActiveRecord::Base
  belongs_to :collection
  belongs_to :collector, polymorphic: true
  validates_presence_of :collection

  attr_accessible :collection, :collection_id, :collector, :collector_id, :collector_type, :uploads_collection
end
