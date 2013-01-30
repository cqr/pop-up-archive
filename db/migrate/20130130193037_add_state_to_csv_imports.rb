class AddStateToCsvImports < ActiveRecord::Migration
  def change
    add_column :csv_imports, :state_index, :integer, default: 0
  end
end
