class Collection < ActiveRecord::Base
  # include ActiveModel::ForbiddenAttributesProtection
  attr_accessible :title, :description

  validates_presence_of :title


  has_many :collection_grants
  has_many :users, through: :collection_grants
end
