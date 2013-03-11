class CsvImportWorker
  include Sidekiq::Worker

  sidekiq_options :timeout => 300, :retry => false, :backtrace => true

  def perform(import_id)
    ActiveRecord::Base.connection_pool.with_connection do
      p  "starting import #{import_id}"
      import = CsvImport.find(import_id)
      CsvImport.transaction do 
        p import
        import.process!
        p import
      end
      p import
      p "transaction complete"
      true
    end
  rescue Exception => e
    ActiveRecord::Base.connection_pool.with_connection do
      p e
      import.error!(e)
      true
    end
    raise e
  end
end