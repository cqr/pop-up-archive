class ChangeOrgAssocToPolymorphicGrant < ActiveRecord::Migration
  def up
    remove_column :collections, :organization_id
    rename_column :collection_grants, :user_id, :collector_id
    add_column :collection_grants, :collector_type, :string
    execute "update collection_grants set collector_type = 'User'"
  end

  def down
    add_column :collections, :organization_id, :integer
    rename_column :collection_grants, :collector_id, :user_id
    remove_column :collection_grants, :collector_type
  end
end
