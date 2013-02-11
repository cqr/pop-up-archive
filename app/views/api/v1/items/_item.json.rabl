attributes :id, :title, :description, :date_created, :identifier, :producers, :interviewees, :creator
attribute :_score => :score
attribute :tags

node(:urls) do |i|
  { self: url_for(api_item_path(i)) }
end
