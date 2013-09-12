require 'spec_helper'

describe Tasks::TranscodeTask do

  before(:each) do 
    @audio_file = FactoryGirl.create :audio_file_private
    @formats = AudioFileUploader.version_formats
    @task = Tasks::TranscodeTask.new(extras: {'formats' => @formats}, owner: @audio_file, identifier: 'transcode')
    @task.save!
  end

  it "should set defaults" do
    task = Tasks::TranscodeTask.new()
    task.should be_valid
    task.save!
    task.default_formats.should == AudioFileUploader.version_formats
    task.formats.should == AudioFileUploader.version_formats
  end

  it "should have formats as hashes" do
    @task.formats.values.each{|v| v.should be_an_instance_of(Hash) }
  end

  it "should be valid with defaults" do
    task = Tasks::TranscodeTask.new(extras:  {'formats' => @formats}, owner: @audio_file, identifier: 'transcode')
    task.owner.should eq @audio_file
    task.identifier.should eq 'transcode'
    task.should be_valid
    task.formats.should_not be_nil
    task.formats.keys.sort.should eq ['mp3', 'ogg']
  end

  it "should have audio_file owner" do
    @task.owner.should_not be_nil
    @task.owner.should eq @task.audio_file
  end

  it "should get the destination for a format" do
    @task.destination('ogg').should start_with('s3://development.popuparchive.prx.org/untitled.')
    @task.destination('ogg').should end_with('.popuparchive.org/test.ogg')
  end

  it "should get the original to be transcoded" do
    @task.original.should start_with('s3://development.popuparchive.prx.org/untitled.')
    @task.original.should end_with('.popuparchive.org/test.mp3')
  end

  it "should add transcode task to job" do
    job = MediaMonster::Job.new
    tasks = @task.add_transcode_task(job, 'test', @task.formats['ogg'])
    task = tasks.first
    task.task_type.should eq 'transcode'
    task.options.should eq @task.formats['ogg']
    task.result.should eq @task.destination('ogg')
    task.call_back.should eq "http://test.popuparchive.org/api/items/#{@audio_file.item.id}/audio_files/#{@audio_file.id}"
    task.label.should eq 'test'
  end

  it "should create a transcode job" do
    job = MediaMonster::Job.new
    @task.should_receive(:create_job).and_yield(job)
    @task.create_transcode_job
    job.job_type.should eq 'audio'
    job.original.should eq @task.original 
    job.priority.should eq 4
    job.call_back.should eq nil
    job.retry_delay.should eq 3600
    job.retry_max.should eq 24
    job.tasks.size.should eq 2
  end

end

