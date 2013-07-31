# encoding: utf-8

require 'utils'

class FeedUpdateWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 0

  def perform(url, collection_id)
    ActiveRecord::Base.connection_pool.with_connection do
      FeedPopUp.update_from_feed(url,collection_id)
    end
  end

end
