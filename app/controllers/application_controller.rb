class ApplicationController < ActionController::Base
  protect_from_forgery

  # decent_configuration do
  #   strategy DecentExposure::StrongParametersStrategy
  # end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end

end
