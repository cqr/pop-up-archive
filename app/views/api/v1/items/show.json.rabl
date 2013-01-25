object item
attributes :id, :title, :description

node(:urls) do |i|
  { self: url_for(api_item_path(i)) }
end
