class CollectionGrant < ActiveRecord::Base
  belongs_to :collection
  belongs_to :user
  # attr_accessible :title, :body
end
