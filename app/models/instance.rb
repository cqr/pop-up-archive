class Instance < ActiveRecord::Base
  belongs_to :item
  has_many   :audio_files, dependent: :destroy
  attr_accessible :digital, :format, :identifier, :item_id, :location
end
