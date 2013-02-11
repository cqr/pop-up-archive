class AddUserIdToCsvImports < ActiveRecord::Migration
  def change
    add_column :csv_imports, :user_id, :integer
    add_index  :csv_imports, :user_id
  end
end
