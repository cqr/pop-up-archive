attributes :id, :title, :description, :items_visible_by_default

node(:urls) do |i|
  { self: url_for(api_collection_path(i)) }
end