class Item < ActiveRecord::Base

  include Tire::Model::Callbacks
  include Tire::Model::Search

  DEFAULT_INDEX_PARAMS = {
    include: [:contributors, :interviewers, :interviewees, :producers, :creator]
  }

  mapping do
    indexes :date_created,      type: 'date',   include_in_all: false
    indexes :date_broadcast,    type: 'date',   include_in_all: false
    indexes :description,       type: 'string'
    indexes :identifier,        type: 'string',  boost: 2.0
    indexes :title,             type: 'string',  boost: 2.0
    indexes :interviewers,      type: 'string',  include_in_all: false, index_name: "interviewer"
    indexes :interviewees,      type: 'string',  include_in_all: false, index_name: "interviewee"
    indexes :producers,         type: 'string',  include_in_all: false
    indexes :tags,              type: 'string',  index_name: "tag", analyzer: "keyword"
    indexes :contributors,      type: 'string',  index_name: "contributor"
    indexes :physical_location, type: 'string'
    indexes :transcription,     type: 'string'
    indexes :location do
      indexes :name
      indexes :position, type: 'geo_point'
    end
  end
  
  attr_accessible :date_broadcast, :date_created, :date_peg,
    :description, :digital_format, :digital_location, :duration,
    :episode_title, :extra, :identifier, :music_sound_used, :notes,
    :physical_format, :physical_location, :rights, :series_title,
    :tags, :title, :transcription
  belongs_to :geolocation
  belongs_to :csv_import
  belongs_to :collection
  has_many   :contributions
  has_many   :audio_files
  has_many   :producer_contributions,    class_name: "Contribution", conditions: {role: "producer"}
  has_many   :interviewer_contributions, class_name: "Contribution", conditions: {role: "interviewer"}
  has_many   :interviewee_contributions, class_name: "Contribution", conditions: {role: "interviewee"}
  has_one    :creator_contribution,      class_name: "Contribution", conditions: {role: "creator"}
  has_many   :contributors, through: :contributions, source: :person
  has_many   :interviewees, through: :interviewee_contributions, source: :person
  has_many   :interviewers, through: :interviewer_contributions, source: :person
  has_many   :producers,    through: :producer_contributions,    source: :person
  has_one    :creator,      through: :creator_contribution,      source: :person
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

  def to_indexed_json(params={})
    as_json(params.reverse_merge(DEFAULT_INDEX_PARAMS)).tap do |json|
      json[:location]     = geolocation.to_indexed_json if geolocation.present?
    end.to_json
  end
end
