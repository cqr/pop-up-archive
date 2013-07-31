# Load the rails application
require File.expand_path('../application', __FILE__)

Mime::Type.register "text/plain", :srt

# Initialize the rails application
PopUpArchive::Application.initialize!
