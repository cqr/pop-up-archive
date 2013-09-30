require 'spec_helper'

describe DownloadTranscriptWorker do
  before { StripeMock.start }
  after { StripeMock.stop }
  it "analyzes transcript" do
    json = '[{"start_time":0,"end_time":9,"text":"from Wednesday January 30th 2013 the following is a replay of the radio doctor daily session in North Carolina House of Representatives","confidence":0.90355223},{"start_time":8,"end_time":17,"text":"tractor seat visitors","confidence":0.8770266}]'

    @task = FactoryGirl.create :transcribe_task
    @worker = DownloadTranscriptWorker.new
    @worker.should_receive(:download_file).and_return(json)
    @worker.perform(@task.id)
  end
end
