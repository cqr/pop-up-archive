class Collection < ActiveRecord::Base
  # include ActiveModel::ForbiddenAttributesProtection
  attr_accessible :title, :description

  belongs_to :default_storage, class_name: "StorageConfiguration"
  has_many :collection_grants
  has_many :users, through: :collection_grants

  validates_presence_of :title

  before_validation :set_defaults

  def set_defaults
    self.copy_media = true if self.copy_media.nil?
  end
end
