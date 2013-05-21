class Contribution < ActiveRecord::Base
  belongs_to :person
  belongs_to :item
  attr_accessible :role, :person, :item, :person_id
end
