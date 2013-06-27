class Task < ActiveRecord::Base
  serialize :extras, HstoreCoder

  attr_accessible :name, :extras, :owner_id, :owner_type, :status, :identifier, :type
  belongs_to :owner, :polymorphic => true

  CREATED  = 'created'
  WORKING  = 'working'
  FAILED   = 'failed'
  COMPLETE = 'complete'

  scope :incomplete, where('status != ?', COMPLETE)

  # convenient scopes for subclass types
  [:analyze, :copy, :transcribe, :upload].each do |task_subclass|
    scope task_subclass, where('type = ?', "Tasks::#{task_subclass.to_s.titleize}Task")
  end

  before_validation(on: :create) do
    self.extras = {} unless extras
  end

  state_machine :status, initial: :created do

    state :created,  value: CREATED
    state :working,  value: WORKING
    state :failed,   value: FAILED
    state :complete, value: COMPLETE

    event :begin do
      transition :created => :working
    end

    event :retry do
      transition :failed => :working
    end

    event :finish do
      transition  all - [:complete] => :complete
    end

    event :failure do
      transition  all - [:failed] => :failed
    end

  end

end
