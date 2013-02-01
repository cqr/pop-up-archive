class ChangeCsvRowValuesLengthTo2048 < ActiveRecord::Migration
  def up
  	change_column :csv_rows, :values, :string, array: true, limit: 10_000_000
  end

  def down

  end
end
