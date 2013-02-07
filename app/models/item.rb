class Item < ActiveRecord::Base

  include Tire::Model::Callbacks
  include Tire::Model::Search
  
  attr_accessible :date_broadcast, :date_created, :date_peg,
    :description, :digital_format, :digital_location, :duration,
    :episode_title, :extra, :identifier, :music_sound_used, :notes,
    :physical_format, :physical_location, :rights, :series_title,
    :tags, :title, :transcription
  belongs_to :geolocation
  belongs_to :csv_import
  has_many  :contributions
  has_many  :producer_contributions,    class_name: "Contribution", conditions: {role: "producer"}
  has_many  :interviewer_contributions, class_name: "Contribution", conditions: {role: "interviewer"}
  has_many  :interviewee_contributions, class_name: "Contribution", conditions: {role: "interviewee"}
  has_one   :creator_contribution,      class_name: "Contribution", conditions: {role: "creator"}
  has_many  :contributors, through: :contributions, source: :person
  has_many  :interviewees, through: :interviewee_contributions, source: :person
  has_many  :interviewers, through: :interviewer_contributions, source: :person
  has_many  :producers,    through: :producer_contributions,    source: :person
  has_one   :creator,      through: :creator_contribution,      source: :person
  serialize :extra, HstoreCoder


  def geographic_location=(name)
    self.geolocation = Geolocation.for_name(name)
  end

  def geographic_location
    geolocation.name
  end

  def creator=(creator)
    self.creators = [creator]
  end
end
