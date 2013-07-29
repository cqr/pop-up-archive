class TimedText < ActiveRecord::Base
  attr_accessible :start_time, :end_time, :text, :confidence
  belongs_to :transcript

  delegate :audio_file, to: :transcript

  def as_json(options = {})
    {audio_file_id: audio_file.id, confidence: confidence, text: text, start_time: start_time, end_time: end_time }
  end

  def as_indexed_json
    as_json.tap do |json|
      json[:transcript] = json.delete :text
    end
  end
end
