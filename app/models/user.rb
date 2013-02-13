class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :name

  before_validation :create_default_collections!

  belongs_to :default_private_collection, class_name: "Collection"
  belongs_to :default_public_collection, class_name: "Collection"

  has_many :collection_grants
  has_many :collections, through: :collection_grants

  def self.find_for_prx_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(
        name: auth.info.name,
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        password: Devise.friendly_token[0,20]
      )
    end
    user
  end

  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first
    unless user
      user = User.create(
        name: auth.info.name,
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        password: Devise.friendly_token[0,20]
      )
    end
    user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.prx_data"]
        user.provider = 'prx'
        user.uid = data['uid']
        user.email = data["email"] if user.email.blank?
        user.name  = data["name"]
      elsif data = session["devise.twitter_data"]
        user.provider = 'twitter'
        user.uid = data['uid']
        user.email = data["email"] if user.email.blank?
        user.name = data["name"]
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
    self.collection_grants = [CollectionGrant.new do |grant|
      grant.user = self
      grant.collection = default_public_collection
    end]
  end
end
