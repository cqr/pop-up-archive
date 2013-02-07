class CsvImportWorker
  include Sidekiq::Worker

  def perform(import_id)
    import = CsvImport.find(import_id)
    import.process!
  rescue Exception => e
    import.error!(e)
  end
end