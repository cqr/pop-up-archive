class FixMultipleGrants < ActiveRecord::Migration
  def up
    pairs = []
    pair = []
    CollectionGrant.find_each do |grant|
      pair = [grant.user_id, grant.collection_id]
      if pairs.include? pair
        grant.delete
      else
        pairs.push pair
      end
    end
    add_index :collection_grants, [:user_id, :collection_id], unique: true
  end

  def down
  end
end
