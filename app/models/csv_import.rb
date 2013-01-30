class CsvImport < ActiveRecord::Base

  STATES = ["new", "queued", "analyzed"]

  attr_accessible :file_name, :file
  after_save :enqueue_processing, on: :create

  validates_presence_of :file

  mount_uploader :file, CsvFileUploader


  def state
    STATES[state_index]
  end

  def analyze!
    raise "Invalid state for analysis: #{state}" if state == 'new'
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
end
