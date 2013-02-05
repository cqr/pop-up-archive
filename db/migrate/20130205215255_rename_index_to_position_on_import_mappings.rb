class RenameIndexToPositionOnImportMappings < ActiveRecord::Migration
  def change
    rename_column :import_mappings, :index, :position
  end
end
