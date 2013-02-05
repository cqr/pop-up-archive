require 'csv'
class CsvImport < ActiveRecord::Base

  STATES = ["new", "queued", "analyzing", "analyzed"]

  attr_accessible :file, :mappings_attributes
  before_save :set_file_name, on: :create
  if Rails.env.test?
    after_save :enqueue_processing, if: :new?
  else
    after_commit :enqueue_processing, if: :new?
  end
  validates_presence_of :file
  mount_uploader :file, ::CsvFileUploader

  has_many :rows, class_name: 'CsvRow'

  has_many :mappings, order: "position", class_name:'ImportMapping' do
    def [](index)
      conditions(['import_mappings.index = ?', index]).limit(1).first
    end
  end
  accepts_nested_attributes_for :mappings

  def state
    STATES[state_index]
  end

  def analyze!
    raise "Invalid state for analysis: #{state}" if %w(new analyzing).include? state
    self.state = "analyzing"
    file.cache!
    CSV.foreach(file.path) do |row|
      if self.headers.present?
        rows.create values: row
      else
        analyze_headers! row
      end
    end
    self.state = "analyzed"
  end

  def new?
    state == 'new'
  end

  private

  def state=(state)
    raise "Invalid state: #{state}" unless new_state_index = STATES.index(state.downcase)
    update_attribute :state_index, new_state_index
  end

  def enqueue_processing
    self.state = "queued"
    CsvImportWorker.perform_async(id) unless Rails.env.test?
  end

  def set_file_name
    self.file_name = File.basename(file.path)
  end

  def analyze_headers!(headers)
    self.headers = headers
    mappings.delete_all

    headers.each_with_index do |header, index|
      column, data_type = case header.downcase
      when /identifier/ then ["identifier", "string"]
      when /interviewee/ then ["interviewee[]", "person"]
      when /piece|title/ then ["title", "string"]
      when /date/ then ["date_created", "date"]
      else [nil, nil]
      end

      mappings.create(data_type:data_type, column:column) do |mapping|
        mapping.position = index
      end
    end
  end 


end
