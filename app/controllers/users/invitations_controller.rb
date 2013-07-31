class Users::InvitationsController < Devise::InvitationsController

  layout 'login'

  before_filter :get_current_invites, :only => [:new, :create]

  def get_current_invites
    @users = User.invitation_not_accepted
  end

  def after_invite_path_for(resource)
    new_user_invitation_path
  end

  # POST /resource/invitation
  def create
    self.resource = resource_class.invite!(invite_params, current_inviter)

    if resource.errors.empty?
      set_flash_message :notice, :send_instructions, :email => self.resource.email
      respond_with resource, :location => after_invite_path_for(resource)
    else
      respond_with_navigational(resource) { render :new }
    end
  end


  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    if params[:invitation_token] && self.resource = resource_class.to_adapter.find_first( :invitation_token => params[:invitation_token] )
      session[:invitation_token] = params[:invitation_token]
      render :edit
    else
      set_flash_message(:alert, :invitation_token_invalid)
      redirect_to after_sign_out_path_for(resource_name)
    end
  end
 
  # PUT /resource/invitation
  def update
    self.resource = resource_class.accept_invitation!(update_resource_params)
 
    if resource.errors.empty?
      session[:invitation_token] = nil
      set_flash_message :notice, :updated
      sign_in(resource_name, resource)
      respond_with resource, :location => after_accept_path_for(resource)
    else
      respond_with_navigational(resource){ render :edit }
    end
  end

  def invite_params
    params.require(resource_name).permit(:email)
  end

  def update_resource_params
    params.require(resource_name).permit(:name, :password, :password_confirmation, :invitation_token)
  end
  
end
