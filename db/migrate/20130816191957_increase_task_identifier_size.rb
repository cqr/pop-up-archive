class IncreaseTaskIdentifierSize < ActiveRecord::Migration
  def up
    change_column :tasks, :identifier, :text
  end

  def down
    change_column :tasks, :identifier, :string
  end
end
