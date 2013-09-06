class AddLanguageToItem < ActiveRecord::Migration
  def change
    add_column :items, :language, :string
  end
end
