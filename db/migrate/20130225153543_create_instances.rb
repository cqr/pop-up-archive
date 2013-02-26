class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.string :identifier
      t.boolean :digital
      t.string :location
      t.string :format
      t.integer :item_id

      t.timestamps
    end
  end
end
