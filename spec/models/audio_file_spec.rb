require 'spec_helper'

describe AudioFile do

  it "should return transcript for legacy transcript text" do
    audio_file = FactoryGirl.build :audio_file
    audio_file.transcript = '[{"start_time":0,"end_time":9,"text":"one","confidence":0.90355223},{"start_time":8,"end_time":17,"text":"two","confidence":0.8770266}]'
    audio_file.transcript_text.should_not be_blank
    audio_file.transcript_text.should eq "one\ntwo"
    audio_file.transcript_array.count.should == 2
  end

  it "should return transcript for timed transcript instead of legacy" do
    json = '[{"start_time":0,"end_time":9,"text":"three","confidence":0.90355223},{"start_time":8,"end_time":17,"text":"four","confidence":0.8770266},{"start_time":16,"end_time":25,"text":"five","confidence":0.8770266}]'
    audio_file = FactoryGirl.build :audio_file
    audio_file.transcript = '[{"start_time":0,"end_time":9,"text":"one","confidence":0.90355223},{"start_time":8,"end_time":17,"text":"two","confidence":0.8770266}]'
    audio_file.process_transcript(json)
    audio_file.transcript_text.should_not be_blank
    audio_file.transcript_text.should eq "three\nfour\nfive"
    audio_file.transcript_array.count.should == 3
    audio_file.transcript_array.collect{|t|t['text']}.join("\n").should eq "three\nfour\nfive"
  end

  it "should process creating a transcript from JSON" do
    json = '[{"start_time":0,"end_time":9,"text":"from Wednesday January 30th 2013 the following is a replay of the radio doctor daily session in North Carolina House of Representatives","confidence":0.90355223},{"start_time":8,"end_time":17,"text":"tractor seat visitors","confidence":0.8770266}]'
    audio_file = FactoryGirl.build :audio_file
    transcript = audio_file.process_transcript(json)
    transcript.timed_texts.count.should == 2
  end

  it "should process creating a transcript from JSON and calculate confidence" do
    json = '[{"start_time":0,"end_time":9,"text":"from Wednesday January 30th 2013 the following is a replay of the radio doctor daily session in North Carolina House of Representatives","confidence":1.0},{"start_time":8,"end_time":17,"text":"tractor seat visitors","confidence":0.0}]'
    audio_file = FactoryGirl.build :audio_file
    transcript = audio_file.process_transcript(json)
    transcript.confidence.should eq 0.5
    transcript.confidence = 0
    transcript.set_confidence.should eq 0.5
    transcript.confidence.should eq 0.5
  end

end
