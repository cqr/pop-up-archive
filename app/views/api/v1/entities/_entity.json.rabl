attributes :id, :name, :is_confirmed, :identifier, :score
attribute entity_type: :type

attribute :category, if: ->(o) { o.category.present? }

node(:extra, if: ->(o) { o.extra.present? })do |n|
  n.extra
end
