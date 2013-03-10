attributes :id, :title, :description, :date_created, :identifier, :producers, :interviewers, :interviewees, :creator, :collection_id
attribute :_score => :score, created_at: :date_added
attribute :tags

node(:urls) do |i|
  { self: url_for(api_item_path(i)) }
end
