class CreateCollectionGrants < ActiveRecord::Migration
  def change
    create_table :collection_grants do |t|
      t.references :collection
      t.references :user

      t.timestamps
    end
    add_index :collection_grants, :collection_id
    add_index :collection_grants, :user_id
  end
end
