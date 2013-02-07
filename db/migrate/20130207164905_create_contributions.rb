class CreateContributions < ActiveRecord::Migration
  def change
    create_table :contributions do |t|
      t.references :person
      t.references :item
      t.string :role

      t.timestamps
    end
    add_index :contributions, :person_id
    add_index :contributions, :item_id
  end
end
