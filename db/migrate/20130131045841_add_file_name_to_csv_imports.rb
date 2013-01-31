class AddFileNameToCsvImports < ActiveRecord::Migration
  def change
    add_column :csv_imports, :file_name, :string
  end
end
