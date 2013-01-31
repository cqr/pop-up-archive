object csv_import
attribute :state
attribute :headers
attribute file_name: :file
node :rows do |import|
  import.rows.map(&:values)
end