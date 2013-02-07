class AddCollectionToCsvImport < ActiveRecord::Migration
  def change
    add_column :csv_imports, :collection_id, :integer
  end
end
