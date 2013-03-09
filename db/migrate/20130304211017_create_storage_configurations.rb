class CreateStorageConfigurations < ActiveRecord::Migration
  def change
    create_table :storage_configurations do |t|
      t.string :provider
      t.string :key
      t.string :secret
      t.string :bucket
      t.string :region
      t.boolean :is_public

      t.timestamps
    end
  end
end
