class CsvImportWorker
  include Sidekiq::Worker

  def perform(import_id)
    import = CsvImport.find(import_id)
    import.process!
  rescue
    import.error!
  end
end