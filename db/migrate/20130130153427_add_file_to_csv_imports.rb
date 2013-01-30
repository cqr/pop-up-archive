class AddFileToCsvImports < ActiveRecord::Migration
  def change
    add_column :csv_imports, :file, :string
  end
end
