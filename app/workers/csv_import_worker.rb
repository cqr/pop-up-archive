class CsvImportWorker
  include Sidekiq::Worker

  def perform(import_id)
    CsvImport.find(import_id)
  end
end