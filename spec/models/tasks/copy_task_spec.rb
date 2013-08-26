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

  it "should update audio file on complete" do

    audio_file = FactoryGirl.create :audio_file
    storage = FactoryGirl.create :storage_configuration_public
    storage_id = storage.id

    task = Tasks::CopyTask.new(
      identifier: 'http://destination.com/file.mp3',
      storage_id: storage_id,
      extras: {
        original:    'http://original.com/file.mp3',
        destination: 'http://destination.com/file.mp3'
      })

    task.owner = audio_file
    task.finish!

  end

end

