class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :name

  after_save :create_default_collections!, if: :needs_default_collections?

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

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.prx_data"]
        user.email = data["email"] if user.email.blank?
        user.name  = "#{data["first_name"]} #{data["last_name"]}"
      end
    end
  end


  private

  def needs_default_collections?
    self.default_public_collection.blank? || self.default_private_collection.blank?
  end

  def create_default_collections!
    (self.default_public_collection  = collections.create(title:"#{name}'s Public Collection"))
    (self.default_private_collection = collections.create(title:"#{name}'s Private Collection"))
    save
  end
end
