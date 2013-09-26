class AddAmaraToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :amara_key, :string
    add_column :organizations, :amara_username, :string
    add_column :organizations, :amara_team, :string
    add_column :organizations, :is_transcriber, :boolean
  end
end
