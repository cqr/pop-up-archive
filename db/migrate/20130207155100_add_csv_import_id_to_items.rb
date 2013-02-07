class AddCsvImportIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :csv_import_id, :integer
    add_index  :items, :csv_import_id
  end
end
