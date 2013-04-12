class Collection < ActiveRecord::Base
  # include ActiveModel::ForbiddenAttributesProtection
  attr_accessible :title, :description, :items_visible_by_default

  belongs_to :default_storage, class_name: "StorageConfiguration"
  has_many :collection_grants, dependent: :destroy
  has_many :users, through: :collection_grants
  has_many :items, dependent: :destroy

  validates_presence_of :title

  before_validation :set_defaults

  scope :is_public, where(items_visible_by_default: true)

  def set_defaults
    self.copy_media = true if self.copy_media.nil?
  end
end
