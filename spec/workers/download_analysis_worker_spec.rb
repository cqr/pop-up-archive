require 'spec_helper'

describe DownloadAnalysisWorker do
  before { StripeMock.start }
  after { StripeMock.stop }
  
  it "processes analysis" do
    json = '{"language":"","topics":[{"name":"Business and finance","score":0.952,"original":"Business_Finance"},{"name":"Hospitality and recreation","score":0.937,"original":"Hospitality_Recreation"},{"name":"Law and crime","score":0.868,"original":"Law_Crime"},{"name":"Entertainment and culture","score":0.587,"original":"Entertainment_Culture"},{"name":"Media","score":0.742268,"original":"Media"}],"tags":[{"name":"cashola","score":0.5}],"entities":[],"relations":[],"locations":[]}'

    @task = FactoryGirl.create :analyze_task
    @worker = DownloadAnalysisWorker.new
    @worker.should_receive(:download_file).and_return(json)
    @worker.perform(@task.id)
  end
end
