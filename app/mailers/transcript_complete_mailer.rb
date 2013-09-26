class TranscriptCompleteMailer < ActionMailer::Base
  default from: ENV['EMAIL_USERNAME']  
end
