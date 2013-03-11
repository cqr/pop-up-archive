class CsvImportWorker
  include Sidekiq::Worker

  def perform(import_id)
    logger.debug("starting import #{import_id}")
    import = CsvImport.find(import_id)
    logger.debug("Got that import")
    import.process!
    logger.debug("Process!")
  rescue Exception => e
    import.error!(e)
  end
end