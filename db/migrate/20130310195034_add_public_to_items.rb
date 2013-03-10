class AddPublicToItems < ActiveRecord::Migration
  def change
    add_column :items, :public, :boolean
  end
end
