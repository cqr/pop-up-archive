class GeocodeWorker
  include Sidekiq::Worker

  def perform(geolocation_id)
    Geolocation.find(geolocation_id).geocode
  end
end