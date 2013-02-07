class AddErrorMessageAndBacktraceToCsvImports < ActiveRecord::Migration
  def change
    add_column :csv_imports, :error_message, :string
    add_column :csv_imports, :backtrace, :text
  end
end
