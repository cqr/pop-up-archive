class CsvImportWorker
  include Sidekiq::Worker

  def perform(import_id)
    p  "starting import #{import_id}"
    import = CsvImport.find(import_id)
    p import
    import.process!
    p import
    true
  rescue Exception => e
    p e
    import.error!(e)
    true
  end
end