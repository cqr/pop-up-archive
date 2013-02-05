class CreateImportMappings < ActiveRecord::Migration
  def change
    create_table :import_mappings do |t|
      t.string :type
      t.string :column
      t.references :csv_import

      t.timestamps
    end
    add_index :import_mappings, :csv_import_id
  end
end
