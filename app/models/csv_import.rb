require 'csv'
class CsvImport < ActiveRecord::Base

  STATES = ["new", "queued", "analyzing", "analyzed"]

  attr_accessible :file
  before_save :set_file_name, on: :create
  after_save :enqueue_processing, on: :create
  validates_presence_of :file
  mount_uploader :file, ::CsvFileUploader
  has_many :rows, class_name: 'CsvRow'


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
        self.headers = row
      end
    end
    self.state = "analyzed"
  end

  private

  def state=(state)
    raise "Invalid state: #{state}" unless self.state_index = STATES.index(state.downcase)
  end

  def enqueue_processing
    CsvImportWorker.perform_async(id) unless Rails.env.test?
    self.state = "queued"
  end

  def set_file_name
    self.file_name = File.basename(file.path)
  end
end
