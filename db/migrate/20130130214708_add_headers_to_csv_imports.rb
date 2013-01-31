class AddHeadersToCsvImports < ActiveRecord::Migration
  def change
    add_column :csv_imports, :headers, :string, array: true
  end
end
