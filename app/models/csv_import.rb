class CsvImport < ActiveRecord::Base
  attr_accessible :file_name
  after_save :enqueue_processing, on: :create


  private

  def enqueue_processing
    CsvImportWorker.perform_async(id) unless Rails.env.test?
  end
end
