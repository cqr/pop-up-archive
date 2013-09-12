require 'spec_helper'

describe CheckUrlWorker do

  it "processes a url" do
    @task = FactoryGirl.create :detect_derivatives_task
    @worker = CheckUrlWorker.new
    @worker.should_receive(:url_exists?).and_return(true)
    @worker.perform(@task.id, 'ogg', 'http://test.popuparchive.org/test.ogg').should eq true
  end

end
