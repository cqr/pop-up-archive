class TimedText < ActiveRecord::Base
  attr_accessible :start_time, :end_time, :text, :confidence
  belongs_to :transcript
end
