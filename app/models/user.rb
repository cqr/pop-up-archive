class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :name

  before_validation :create_default_collections!, on: :create

  belongs_to :default_private_collection, class_name: "Collection"
  belongs_to :default_public_collection, class_name: "Collection"

  has_many :collection_grants
  has_many :collections, through: :collection_grants


  def self.find_for_oauth(auth, signed_in_resource=nil)
    where(provider: auth.provider, uid: auth.uid).first || (create do |user|
      user.provider = auth.provider
      user.uid      = auth.uid 
      user.name     = auth.info.name
      user.email    = auth.info.email
      user.password = Devise.friendly_token[0,20]
    end)
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.oauth_data"]
        user.provider = data['provider']
        user.uid      = data['uid']
        user.email    = data["email"] if user.email.blank?
        user.name     = data["name"] if user.name.blank?
        user.valid? if data[:should_validate]
      end
    end
  end

  def password_required?
    !provider.present?
  end

  def name_required?
    !provider.present? || !name.present?
  end

  private

  def create_default_collections!
    self.default_public_collection = Collection.new(title:"#{name}'s Public Collection")
    self.collection_grants += [CollectionGrant.new do |grant|
      grant.user = self
      grant.collection = default_public_collection
    end]
  end
end
