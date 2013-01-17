class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  DATA_KEYS = ['email', 'first_name', 'last_name']

  # I think we should switch the name of the provider to Prx so this can be lowercase
  def prx
    @user = User.find_for_prx_oauth(request.env['omniauth.auth'], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
      set_flash_message :notice, :success, :kind => "PRX" if is_navigational_format?
    else
      session['devise.prx_data'] = extract_keys(DATA_KEYS, request.env['omniauth.auth']['info'])

      redirect_to new_user_registration_url
    end
  end

  private

  def extract_keys(keys, hash)
    Hash[keys.zip(hash.values_at(*keys))]
  end
end