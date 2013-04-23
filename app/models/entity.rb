class Entity < ActiveRecord::Base
  attr_accessible :entity_type, :extra, :identifier, :is_confirmed, :item_id, :name, :score

  serialize :extra

  belongs_to :item

end
