# encoding: utf-8

class GeocodeWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 25

  def perform(geolocation_id)
    ActiveRecord::Base.connection_pool.with_connection do
      location = Geolocation.find geolocation_id
      location.geocode
      location.save
      true
    end
  end
end
