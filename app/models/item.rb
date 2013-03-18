class Item < ActiveRecord::Base

  include Tire::Model::Callbacks
  include Tire::Model::Search

  belongs_to :storage, class_name: "StorageConfiguration", foreign_key: :storage_id
  before_validation :set_public, if: :new_record? 

  DEFAULT_INDEX_PARAMS = {}

  tire do
    mapping do
      indexes :id, index: :not_analyzed
      indexes :public, index: :not_analyzed
      indexes :collection_id, index: :not_analyzed
      indexes :date_created,      type: 'date',   include_in_all: false
      indexes :date_broadcast,    type: 'date',   include_in_all: false
      indexes :created_at,        type: 'date',   include_in_all: false, index_name:"date_added"
      indexes :description,       type: 'string'
      indexes :identifier,        type: 'string',  boost: 2.0
      indexes :title,             type: 'string',  boost: 2.0
      indexes :interviewers,      type: 'string',  include_in_all: false, index_name: "interviewer", index: "not_analyzed"
      indexes :interviewees,      type: 'string',  include_in_all: false, index_name: "interviewee", index: "not_analyzed"
      indexes :producers,         type: 'string',  include_in_all: false, index_name: "producer",    index: "not_analyzed"
      indexes :tags,              type: 'string',  index_name: "tag",                                index: "not_analyzed"
      indexes :contributors,      type: 'string',  index_name: "contributor"
      indexes :physical_location, type: 'string'
      indexes :transcription,     type: 'string'
      indexes :duration,          type: 'long',    include_in_all: false
      indexes :location do
        indexes :name
        indexes :position, type: 'geo_point'
      end
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
  has_many :collection_grants, through: :collection
  has_many :users, through: :collection_grants

  has_many   :contributions
  has_many   :instances
  has_many   :audio_files
  has_many   :producer_contributions,    class_name: "Contribution", conditions: {role: "producer"}
  has_many   :interviewer_contributions, class_name: "Contribution", conditions: {role: "interviewer"}
  has_many   :interviewee_contributions, class_name: "Contribution", conditions: {role: "interviewee"}
  has_many   :creator_contributions,     class_name: "Contribution", conditions: {role: "creator"}
  has_many   :contributors, through: :contributions, source: :person
  has_many   :interviewees, through: :interviewee_contributions, source: :person
  has_many   :interviewers, through: :interviewer_contributions, source: :person
  has_many   :producers,    through: :producer_contributions,    source: :person
  has_many   :creators,     through: :creator_contributions,     source: :person
  serialize :extra, HstoreCoder

  delegate :title, to: :collection, prefix: true

  @@instance_lock = Mutex.new

  def token
    read_attribute(:token) || generate_token
  end

  def generate_token
    @@instance_lock.synchronize do
      begin
        t = "#{(self.title||'untitled')[0,50].parameterize}_" + SecureRandom.urlsafe_base64(6)
      end while Item.where(:token => t).exists?
      self.update_attribute(:token, t)
      t
    end
  end

  def geographic_location=(name)
    self.geolocation = Geolocation.for_name(name)
  end

  def geographic_location
    geolocation.name
  end

  def creator=(creator)
    self.creators = [creator]
  end

  def creator
    self.creators.try(:first)
  end

  def update_transcription!
    self.transcription = transcript_text
    self.save!
  end

  def transcript_text
    audio_files.collect{|af| af.transcript_text}.join("\n")
  end

  def to_indexed_json(params={})
    as_json(params.reverse_merge(DEFAULT_INDEX_PARAMS)).tap do |json|
      [:contributors, :interviewers, :interviewees, :producers, :creators].each do |assoc|
        json[assoc] = send(assoc).map{|c| c.as_json } 
      end
      json[:location]     = geolocation.to_indexed_json if geolocation.present?
    end.to_json
  end

  private

  def set_public
    if collection.present? && public.nil?
      self.public = collection.items_visible_by_default
    elsif public.nil?
      self.public = false
    end

    return true
  end

end
