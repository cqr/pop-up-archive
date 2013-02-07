object item
attributes :id, :title, :description, :date_created, :identifier

node(:producers) do |i|
  i.producers.map do |producer|
    {id:producer.id, name:producer.name}
  end
end

node(:interviewees) do |i|
  i.interviewees.map do |interviewee|
    {id:interviewee.id, name:interviewee.name}
  end
end

node(:urls) do |i|
  { self: url_for(api_item_path(i)) }
end
