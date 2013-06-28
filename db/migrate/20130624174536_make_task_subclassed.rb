class MakeTaskSubclassed < ActiveRecord::Migration
  def up
    add_column :tasks, :type, :string
  end

  def down
    remove_column :tasks, :type
  end
end
