class AudioFile < ActiveRecord::Base
  belongs_to :item
  attr_accessible :file
end
