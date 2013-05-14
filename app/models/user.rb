class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :name, :invitation_token

  has_many :collection_grants
  has_many :collections, through: :collection_grants
  has_many :items, through: :collections
  has_many :csv_imports

  validates_presence_of :invitation_token, if: :invitation_token_required?
  validates_presence_of :name, if: :name_required?

  after_invitation_accepted :add_public_collection

  def self.find_for_oauth(auth, signed_in_resource=nil)
    find_invited(auth) ||
    where(provider: auth.provider, uid: auth.uid).first || 
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

  private

  def add_public_collection
    collection = Collection.new(title: "#{name}'s Collection", items_visible_by_default: true)
    collection.users << self
    collection.save
  end
end
