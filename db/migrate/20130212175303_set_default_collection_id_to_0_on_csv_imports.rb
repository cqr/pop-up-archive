class SetDefaultCollectionIdTo0OnCsvImports < ActiveRecord::Migration
  def change
    change_column :csv_imports, :collection_id, :integer, default: 0
  end
end
