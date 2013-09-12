require 'spec_helper'

describe Tasks::TranscodeTask do

  it "should set defaults" do
    task = Tasks::TranscodeTask.new()
    task.should be_valid
  end

end

