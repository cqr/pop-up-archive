class Item < ActiveRecord::Base

  include Tire::Model::Callbacks
  include Tire::Model::Search

  DEFAULT_INDEX_PARAMS = {}
  
  STANDARD_ROLES = ['producer', 'interviewer', 'interviewee', 'creator', 'host']

  before_validation :set_defaults, if: :new_record?

  validate :collection_changes

  tire do
    mapping do
      indexes :id, index: :not_analyzed
      indexes :is_public, index: :not_analyzed
      indexes :collection_id, index: :not_analyzed
      indexes :date_created,      type: 'date',   include_in_all: false
      indexes :date_broadcast,    type: 'date',   include_in_all: false
      indexes :created_at,        type: 'date',   include_in_all: false, index_name:"date_added"
      indexes :description,       type: 'string'
      indexes :identifier,        type: 'string',  boost: 2.0
      indexes :title,             type: 'string',  boost: 2.0
      indexes :tags,              type: 'string',  index_name: "tag",    index: "not_analyzed"
      indexes :contributors,      type: 'string',  index_name: "contributor"
      indexes :physical_location, type: 'string'
      indexes :transcription,     type: 'string'
      indexes :duration,          type: 'long',    include_in_all: false
      indexes :location do
        indexes :name
        indexes :position, type: 'geo_point'
      end

      indexes :entities do 
        indexes :name, type: 'string'
        indexes :category, type: 'string'
      end

      STANDARD_ROLES.each do |role|
        indexes role.pluralize.to_sym, type: 'string', include_in_all: false, index_name: role, index: "not_analyzed"
      end

    end
  end
  
  attr_accessible :date_broadcast, :date_created, :date_peg,
    :description, :digital_format, :digital_location, :duration,
    :episode_title, :extra, :identifier, :music_sound_used, :notes,
    :physical_format, :physical_location, :rights, :series_title,
    :tags, :title, :transcription, :adopt_to_collection

  belongs_to :geolocation
  belongs_to :csv_import
  belongs_to :storage_configuration, class_name: "StorageConfiguration", foreign_key: :storage_id
  belongs_to :collection

  has_many   :collection_grants, through: :collection
  has_many   :users, through: :collection_grants

  has_many   :instances, dependent: :destroy
  has_many   :audio_files, dependent: :destroy

  has_many   :contributions, dependent: :destroy
  has_many   :contributors, through: :contributions, source: :person
  
  has_many   :entities, dependent: :destroy
  
  STANDARD_ROLES.each do |role|
    has_many "#{role}_contributions".to_sym, class_name: "Contribution", conditions: {role: role}
    has_many role.pluralize.to_sym, through: "#{role}_contributions".to_sym, source: :person
  end

  default_scope includes(:contributors, :interviewees, :interviewers, :hosts, :creators, :producers, :geolocation)

  serialize :extra, HstoreCoder

  delegate :title, to: :collection, prefix: true

  accepts_nested_attributes_for :contributions

  @@instance_lock = Mutex.new

  def process_analysis(analysis)
    analysis = JSON.parse(analysis) if analysis.is_a?(String)
    ["entities", "locations", "relations", "tags", "topics"].each do |category|
      analysis[category].each{|analysis_entity|
        entity = self.entities.build
        entity.category     = category.try(:singularize)
        entity.entity_type  = analysis_entity.delete('type')
        entity.is_confirmed = false
        entity.name         = analysis_entity.delete('name')
        entity.identifier   = analysis_entity.delete('guid')
        entity.score        = analysis_entity.delete('score')

        # anything left over, put it in the extra
        entity.extra        = analysis_entity
        entity.save
      }
    end
  end

  def token
    read_attribute(:token) || generate_token
  end

  def generate_token
    @@instance_lock.synchronize do
      begin
        t = "#{(self.title||'untitled')[0,50].parameterize}." + SecureRandom.urlsafe_base64(6) + ".popuparchive.org"
      end while Item.where(:token => t).exists?
      self.update_attribute(:token, t)
      t
    end
  end

  def storage
    self.storage_configuration || self.collection.try(:default_storage) || StorageConfiguration.default_storage(is_public)
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
      ([:contributors] + STANDARD_ROLES.collect{|r| r.pluralize.to_sym}).each do |assoc|
        json[assoc] = send(assoc).map{|c| c.as_json } 
      end
      json[:tags]     = tags_for_index
      json[:location] = geolocation.to_indexed_json if geolocation.present?
    end.to_json
  end

  def tags
    super || self.tags = []
  end

  def adopt_to_collection=(collection_id)
    self.collection_id = collection_id
  end

  private

  def set_defaults
    return true unless is_public.nil?
    self.is_public = (collection.present? && collection.items_visible_by_default)
    self.storage_configuration = self.storage
    true
  end

  def tags_for_index
    tfi = tags.dup
    tags.each do |tag|
      parts = tag.split('/')
      1.upto(parts.size-1) do |number|
        tfi.push(parts[0...number].join('/'))
      end
    end
    tfi
  end

  def collection_changes
    if collection_id_changed? && collection_id_was != nil
      errors.add(:collection, "cannot be changed once set") unless Collection.find(collection_id_was).uploads_collection?
    end
  end

end
