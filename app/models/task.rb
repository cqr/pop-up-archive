class Task < ActiveRecord::Base
  serialize :extras, HstoreCoder

  attr_accessible :name, :extras, :owner_id, :owner_type, :status, :identifier
  belongs_to :owner, :polymorphic => true

  CREATED  = 'created'
  WORKING  = 'working'
  FAILED   = 'failed'
  COMPLETE = 'complete'

  scope :incomplete, where('status != ?', COMPLETE)
  scope :complete, where('status = ?', COMPLETE)

end
