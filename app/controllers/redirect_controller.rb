class RedirectController < ApplicationController
  def perform
    redirect_to "/#/#{params[:path]}"
  end
end