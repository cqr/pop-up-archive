object csv_import

attribute :state, :headers, :id
attribute file_name: :file

node :preview_rows do |import|
  import.rows.limit(5).order('random()').map(&:values)
end

node(:urls) do |i|
  { self: url_for(api_item_path(i)) }
end
