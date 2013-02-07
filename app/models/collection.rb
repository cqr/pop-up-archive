class Collection < ActiveRecord::Base
  # include ActiveModel::ForbiddenAttributesProtection
  attr_accessible :title, :description

  validates_presence_of :title
end
