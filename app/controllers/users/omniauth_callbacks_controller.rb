class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # I think we should switch the name of the provider to Prx so this can be lowercase
  def PRX
    @user = User.find_for_prx_oauth(request.env['omniauth.auth'], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
      set_flash_message :notice, :success, :kind => "PRX" if is_navigational_format?
    else
      session['devise.prx_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end

end