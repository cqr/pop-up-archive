require 'spec_helper'

describe Tasks::CopyTask do

  it "should set defaults" do

    task = Tasks::CopyTask.new(
      identifier: 'http://destination.com/file.mp3',
      storage_id: 2,
      extras: {
        original:    'http://original.com/file.mp3',
        destination: 'http://destination.com/file.mp3'
      })

    task.should be_valid
    task.identifier.should eq('http://destination.com/file.mp3')
  end

end

