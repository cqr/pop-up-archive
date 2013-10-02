# Load the rails application
require File.expand_path('../application', __FILE__)

Mime::Type.register "text/plain", :srt
Mime::Type.register "text/plain", :txt

# Initialize the rails application
PopUpArchive::Application.initialize!
