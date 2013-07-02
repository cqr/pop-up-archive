class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :name, :invitation_token

  has_many :collection_grants
  has_one  :uploads_collection_grant, class_name: 'CollectionGrant', conditions: {uploads_collection: true}
  has_one  :uploads_collection, through: :uploads_collection_grant, source: :collection
  has_many :collections, through: :collection_grants
  has_many :items, through: :collections
  has_many :csv_imports
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner

  validates_presence_of :invitation_token, if: :invitation_token_required?
  validates_presence_of :name, if: :name_required?
  validates_presence_of :uploads_collection

  def self.find_for_oauth(auth, signed_in_resource=nil)
    where(provider: auth.provider, uid: auth.uid).first || 
    find_invited(auth) ||
    create{|user| user.apply_oauth(auth)}
  end

  def self.find_invited(auth)
    user = where(invitation_token: auth.invitation_token).first if auth.invitation_token
    user = where(email: auth.info.email).first if !user && auth.info.email
    user.apply_oauth(auth) if user
    user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.oauth_data"]
        user.provider = data['provider']
        user.uid      = data['uid']
        user.email    = data["email"] if user.email.blank?
        user.name     = data["name"] if user.name.blank?
        user.invitation_token = session[:invitation_token]
        user.valid? if data[:should_validate]
      end
    end
  end

  def apply_oauth(auth)
    self.provider = auth.provider
    self.uid      = auth.uid
    self.name     = auth.info.name
    self.email    = auth.info.email
  end

  def password_required?
    # logger.debug "password_required? checked on #{self.inspect}\n"
    !provider.present? && !@skip_password && super
  end

  def name_required?
    # logger.debug "name_required? checked on #{self.inspect}\n"
    !provider.present? && !@skip_password && !name.present?
  end

  def invitation_token_required?
    !invitation_accepted_at.present?
  end

  def uploads_collection
    super || add_uploads_collection
  end

  def searchable_collection_ids
    collection_ids - [uploads_collection.id]
  end

  private

  def add_uploads_collection
    self.uploads_collection = Collection.new(title: "My Uploads", items_visible_by_default: false)
    build_uploads_collection_grant collection: uploads_collection
    uploads_collection
  end
end
