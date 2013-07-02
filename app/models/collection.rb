class Collection < ActiveRecord::Base

  acts_as_paranoid

  # include ActiveModel::ForbiddenAttributesProtection
  attr_accessible :title, :description, :items_visible_by_default

  belongs_to :default_storage, class_name: "StorageConfiguration"
  belongs_to :upload_storage, class_name: "StorageConfiguration"

  has_many :collection_grants, dependent: :destroy

  has_many  :uploads_collection_grants, class_name: 'CollectionGrant', conditions: {uploads_collection: true}

  has_many :users, through: :collection_grants
  has_many :items, dependent: :destroy

  validates_presence_of :title

  before_validation :set_defaults

  scope :is_public, where(items_visible_by_default: true)

  before_validation :set_storage

  validate :validate_storage

  def validate_storage
    errors.add(:default_storage, "must be set") if !default_storage
    errors.add(:upload_storage, "must be set when storage is public") if (!upload_storage && items_visible_by_default)
  end

  def upload_to
    upload_storage || default_storage
  end

  def set_storage
    self.default_storage = StorageConfiguration.default_storage(items_visible_by_default) if !default_storage
    self.upload_storage  = StorageConfiguration.private_storage if (!upload_storage && items_visible_by_default)
  end

  def set_defaults
    self.copy_media = true if self.copy_media.nil?
  end

  def uploads_collection?
    uploads_collection_grants.present?
  end
end
