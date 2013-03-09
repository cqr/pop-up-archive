class AddTokenToItems < ActiveRecord::Migration
  def change
    add_column :items, :token, :string
  end
end
