class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.boolean :is_confirmed
      t.string :identifier
      t.string :name
      t.float :score
      t.string :category
      t.string :entity_type
      t.integer :item_id
      t.text :extra

      t.timestamps
    end
    add_index :entities, :item_id
  end
end
