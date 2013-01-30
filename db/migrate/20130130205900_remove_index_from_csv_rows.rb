class RemoveIndexFromCsvRows < ActiveRecord::Migration
  def up
    remove_column :csv_rows, :index
  end

  def down
    add_column :csv_rows, :index, :integer
  end
end
