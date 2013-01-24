class ReplaceLatlonWithLatitudeAndLongitudeOnGeolocations < ActiveRecord::Migration
  def change
    add_column :geolocations, :latitude, :decimal
    add_column :geolocations, :longitude, :decimal

    remove_column :geolocations, :latlon
  end
end 
