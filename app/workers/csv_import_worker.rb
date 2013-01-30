class CsvImportWorker
  include Sidekiq::Worker

  def perform(import_id)
    import = CsvImport.find(import_id)
    import.analyze!
  end
end