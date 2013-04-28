attributes :id, :title, :description, :date_created, :identifier, :collection_id, :episode_title, :series_title, :date_broadcast, :physical_format, :digital_format, :digital_location, :physical_location, :music_sound_used, :date_peg, :rights, :duration, :tags, :notes

Item::STANDARD_ROLES.each{|r| attribute r.pluralize.to_sym}

attribute :_score => :score, created_at: :date_added

child :audio_files do |af|
  extends 'api/v1/audio_files/audio_file'
end

child :entities do |e|
  extends 'api/v1/entities/entity'
end

node :extra do |i|
  i.extra
end

node(:urls) do |i|
  { self: url_for(api_item_path(i)) }
end
