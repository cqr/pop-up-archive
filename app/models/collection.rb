class Collection < ActiveRecord::Base
  # include ActiveModel::ForbiddenAttributesProtection
  attr_accessible :title, :description

  belongs_to :default_storage, class_name: "StorageConfiguration"

  validates_presence_of :title

  before_validation :set_defaults

  def set_defaults
  	self.copy_media = true if self.copy_media.nil?
  end

end
