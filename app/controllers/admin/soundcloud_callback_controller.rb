class Admin::SoundcloudCallbackController < ApplicationController
  def index
    code = params[:code]
    puts "Soundcloud code: " + code unless code.nil?
  end
end
