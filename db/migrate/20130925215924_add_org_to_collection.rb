class AddOrgToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :organization_id, :integer
    add_column :collections, :creator_id, :integer
  end
end
