class RenameTypeToDataTypeInImportMappings < ActiveRecord::Migration
  def change
    rename_column :import_mappings, :type, :data_type
  end
end
