class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  DATA_KEYS = ['email', 'name']

  # I think we should switch the name of the provider to Prx so this can be lowercase
  def prx
    @user = User.find_for_prx_oauth(request.env['omniauth.auth'], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
      set_flash_message :notice, :success, :kind => "PRX" if is_navigational_format?
    else
      session['devise.prx_data'] = extract_keys(DATA_KEYS, request.env['omniauth.auth']['info'])
      session['devise.prx_data']['uid'] = @user.uid
      redirect_to new_user_registration_url
    end
  end

  def twitter
    @user = User.find_for_twitter_oauth(request.env['omniauth.auth'], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
    else
      session['devise.twitter_data'] = extract_keys(DATA_KEYS, request.env['omniauth.auth']['info'])
      session['devise.twitter_data']['uid'] = @user.uid
      redirect_to new_user_registration_url, notice: "We need your email address to finish signing you in with Twitter."
    end
  end

  def facebook
    @user = User.find_for_facebook_oauth(request.env['omniauth.auth'], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
    else
      session['devise.facebook_data'] = extract_keys(DATA_KEYS, request.env['omniauth.auth']['info'])
      session['devise.facebook_data']['uid'] = @user.uid
      redirect_to new_user_registration_url, notice: "We need some more information to finish signing you in with Facebook."
    end
  end

  private

  def extract_keys(keys, hash)
    Hash[keys.zip(hash.values_at(*keys))]
  end
end