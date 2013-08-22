class Users::RegistrationsController < Devise::RegistrationsController

  before_filter :update_sign_up_filter

  protected

  def build_resource(*args)
    hash = args[0] || resource_params || {}
    
    invited = nil
    if hash[:invitation_token]
      invited = resource_class.where(:invitation_token => hash[:invitation_token], :invitation_accepted_at => nil).first
    elsif hash[:email]
      invited = resource_class.where(:email => hash[:email], :encrypted_password => '').first
    end

    if invited
      self.resource = invited
      self.resource.attributes = hash
      self.resource.accept_invitation
    end

    self.resource ||= super
  end

  def update_sign_up_filter
    devise_parameter_sanitizer.for(:sign_up) do |default_params|
      default_params.permit(:name, :password, :password_confirmation, :email, :invitation_token, :provider, :uid)
    end
  end
end
