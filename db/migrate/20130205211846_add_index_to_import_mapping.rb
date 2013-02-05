class AddIndexToImportMapping < ActiveRecord::Migration
  def change
    add_column :import_mappings, :index, :integer
  end
end
