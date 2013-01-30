class CsvImport < ActiveRecord::Base
  attr_accessible :file_name, :file
  after_save :enqueue_processing, on: :create

  validates_presence_of :file

  mount_uploader :file, CsvFileUploader


  private

  def enqueue_processing
    CsvImportWorker.perform_async(id) unless Rails.env.test?
  end
end
