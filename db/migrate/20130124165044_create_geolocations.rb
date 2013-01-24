class CreateGeolocations < ActiveRecord::Migration
  def change
    create_table :geolocations do |t|
      t.string :name
      t.string :slug
      t.decimal :latlon, array: true

      t.timestamps
    end
  end
end
