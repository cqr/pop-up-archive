Slim::Engine.set_default_options :pretty => true unless Rails.env.production?
Rails.application.assets.register_mime_type 'text/html', '.html'
Rails.application.assets.register_engine '.slim', Slim::Template
Sprockets.register_engine '.slim', Slim::Template
module Sprockets::Helpers::RailsHelper
  def render_partial(*args)
    "Gooooood."
  end
end