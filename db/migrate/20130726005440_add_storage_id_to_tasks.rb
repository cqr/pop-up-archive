class AddStorageIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :storage_id, :integer
  end
end
