object csv_import

attribute :state, :headers, :id, :created_at, :collection_id
attribute file_name: :file

node :row_count do |i|
  i.rows.size
end

node(:mappings) do |import|
  import.mappings.map do |mapping|
    {column: mapping.column, type: mapping.data_type}
  end
end

node :preview_rows do |import|
  import.rows.limit(5).order('random()').map(&:values)
end

node(:urls) do |import|
  { self: url_for(api_item_path(import)) }
end
