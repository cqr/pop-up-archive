class Transcript < ActiveRecord::Base
  attr_accessible :language, :audio_file_id, :identifier, :start_time, :end_time

  belongs_to :audio_file
  has_many :timed_texts, order: 'start_time ASC'
end
