class AddDefaultVisibilityToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :items_visible_by_default, :boolean, default: false
  end
end
