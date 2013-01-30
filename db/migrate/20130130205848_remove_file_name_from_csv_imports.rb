class RemoveFileNameFromCsvImports < ActiveRecord::Migration
  def up
    remove_column :csv_imports, :file_name
  end

  def down
    add_column :csv_imports, :file_name, :string
  end
end
