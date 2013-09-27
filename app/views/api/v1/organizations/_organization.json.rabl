attributes :id
attributes :name
attributes :amara_team

child :users do |u|
  attributes :id, :name, :role
end
