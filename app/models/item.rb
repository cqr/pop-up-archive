class Item < ActiveRecord::Base
  
  attr_accessible :date_broadcast, :date_created, :date_peg,
    :description, :digital_format, :digital_location, :duration,
    :episode_title, :extra, :identifier, :music_sound_used, :notes,
    :physical_format, :physical_location, :rights, :series_title,
    :tags, :title, :transcription
  belongs_to :geolocation
  serialize :extra, ActiveRecord::Coders::Hstore


  def geographic_location=(name)
    self.geolocation = Geolocation.for_name(name)
  end

  def geographic_location
    geolocation.name
  end

  def extra
    (read_attribute :extra) or (write_attribute :extra, {})
  end
end

