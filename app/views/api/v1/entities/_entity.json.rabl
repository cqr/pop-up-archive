attributes :id, :name, :category, :is_confirmed, :identifier, :score
attribute :entity_type=>:type

node :extra do |n|
  n.extra
end
