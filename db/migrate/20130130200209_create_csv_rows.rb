class CreateCsvRows < ActiveRecord::Migration
  def change
    create_table :csv_rows do |t|
      t.string :values, array: true
      t.references :csv_import
      t.integer :index

      t.timestamps
    end
    add_index :csv_rows, :csv_import_id
  end
end
