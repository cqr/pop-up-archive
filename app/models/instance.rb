class Instance < ActiveRecord::Base
  belongs_to :item
  has_many   :audio_files
  attr_accessible :digital, :format, :identifier, :item_id, :location
end
