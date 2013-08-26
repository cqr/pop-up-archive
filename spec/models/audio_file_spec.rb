require 'spec_helper'

describe AudioFile do

  context "transcoding" do

    it "should use the version label as the extension" do
      audio_file = FactoryGirl.create :audio_file
      File.basename(audio_file.file.mp3.url).should eq "test.mp3"
      File.basename(audio_file.file.ogg.url).should eq "test.ogg"
    end

  end

  context "copy and move collections" do

    it "should not create a copy task for current storage id" do

      audio_file = FactoryGirl.build :audio_file

      audio_file.storage.id.should eq(audio_file.item.storage.id)
      audio_file.copy_to_item_storage.should == false

      audio_file.storage_configuration = FactoryGirl.build :storage_configuration_private

      a_sid = audio_file.storage.id
      i_sid = audio_file.item.storage.id
      a_sid.should_not eq(i_sid)
      audio_file.copy_to_item_storage.should == true
    end

    it "should handle a remote url with query string" do
      audio_file = AudioFile.new
      audio_file.remote_file_url = "http://www.prx.org/test?query=string"
      audio_file.storage_configuration = FactoryGirl.build :storage_configuration_public
      audio_file.destination_path.should == '/test'
    end

  end

  context "transcripts" do

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
      transcript.set_confidence.should eq 0.5
      transcript.confidence.should eq 0.5
    end

  end
end
