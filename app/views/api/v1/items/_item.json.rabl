attributes :id, :title, :description, :date_created, :identifier, :producers, :interviewers, :interviewees, :creator, :collection_id
attributes :episode_title, :series_title, :date_broadcast, :date_created, :physical_format, :digital_format, :digital_location, :physical_location, :music_sound_used, :date_peg, :rights, :duration
attribute :_score => :score, created_at: :date_added
attribute :tags
attribute :transcription

child :audio_files do |af|
  extends 'api/v1/audio_files/audio_file'
end

node :extra do |i|
  i.extra
end

node(:urls) do |i|
  { self: url_for(api_item_path(i)) }
end
