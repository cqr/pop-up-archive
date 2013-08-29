require 'digest/md5'

class MediaController < ApplicationController

  def show
    version = nil
    asset = params[:class].camelize.constantize.find(params[:id])
    if asset.public_url_token_valid?(params[:token], params)
      version = params[:extension] ? params[:extension].to_sym : nil
      url = asset.url(version)
      redirect_to url
    else
      head 401
    end
  end

end
