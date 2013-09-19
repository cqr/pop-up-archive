require 'spec_helper'

describe Tasks::OrderTranscriptTask do

  before(:each) do 
    @audio_file = FactoryGirl.create :audio_file
    @task = Tasks::OrderTranscriptTask.new(owner: @audio_file, identifier: 'order_transcript')
    @task.save!
  end

  it "should be valid with defaults" do
    task = Tasks::OrderTranscriptTask.new(owner: @audio_file, identifier: 'order_transcript')
    task.owner.should eq @audio_file
    task.identifier.should eq 'order_transcript'
    task.should be_valid
  end

  it "should return the video_id" do
    @task.extras['video_id'] = 'RANDOM'
    @task.video_id.should eq 'RANDOM'
  end

  it "should have an edit transcript url" do
    @task.extras['video_id'] = 'RANDOM'
    @task.edit_video_transcript_url.should eq "http://www.amara.org/en/subtitles/editor/RANDOM/en/"
  end

  it "should have audio_file owner" do
    @task.owner.should_not be_nil
    @task.owner.should eq @task.audio_file
  end

  it "should set amara_options" do
    @task.amara_options.should_not be_nil
    @task.amara_options.keys.sort.should eq [:primary_audio_language_code, :team, :title, :video_url]
    @task.amara_options[:primary_audio_language_code].should eq 'en'
    @task.amara_options[:team].should eq 'prx-test-1'
    @task.amara_options[:title].should eq @audio_file.filename
    @task.amara_options[:video_url].should eq @audio_file.public_url(extension: :ogg)
  end

  it "should order the transcript and add video id to task" do
    video = Hashie::Mash.new({id: 'NEWVIDEO'})
    @task.should_receive(:create_video).and_return(video)
    @task.order_transcript
    @task.video_id.should eq 'NEWVIDEO'
  end

  it "should call amara to create the video" do
    video = Hashie::Mash.new({id: 'NEWVIDEO'})
    response = Hashie::Mash.new({body: video, status: 200})
    amara_response = Amara::Response.new(response)
    @task.amara_client.videos.should_receive(:create).and_return(amara_response)
    @task.create_video.should eq video
  end
end