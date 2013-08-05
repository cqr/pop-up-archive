class AddIndexesToTables < ActiveRecord::Migration
  def change
    add_index :entities, [:is_confirmed, :item_id, :score]
    add_index :items, [:id, :deleted_at]
    add_index :audio_files, [:item_id, :deleted_at]
    add_index :contributions, [:role, :item_id]
  end
end
