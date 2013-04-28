# encoding: utf-8

class CsvImportWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false, :backtrace => true

  def perform(import_id)
    ActiveRecord::Base.connection_pool.with_connection do
      import = CsvImport.find(import_id)
      CsvImport.transaction do
        import.process!
      end
      true
    end
  rescue Exception => e
    ActiveRecord::Base.connection_pool.with_connection do
      p e
      if defined? import
        import.error!(e)
      end
      true
    end
    raise e
  end
end
