class Users::RegistrationsController < Devise::RegistrationsController

  protected

  def build_resource(*args)
    logger.debug "Users::Registrations: start! #{args.inspect}"
    hash = args.pop || resource_params || {}
    
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
end
