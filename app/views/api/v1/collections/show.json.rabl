object kollection
attributes :id, :title, :description

node(:urls) do |i|
  { self: url_for(api_collection_path(i)) }
end
