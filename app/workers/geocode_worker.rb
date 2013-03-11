# encoding: utf-8

class GeocodeWorker
  include Sidekiq::Worker

  def perform(geolocation_id)
    location = Geolocation.find geolocation_id
    location.geocode
    location.save
  end
end
