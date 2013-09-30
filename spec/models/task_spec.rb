require 'spec_helper'

describe Task do
  before { StripeMock.start }
  after { StripeMock.stop }
  
  it "should allow writing to the extras attributes" do
    task = FactoryGirl.build :task
    task.extras = {test: 'test value'}
    task.save
  end

  it 'should persist the extras attributes' do
    task = FactoryGirl.create :task
    task.extras = {test: 'test value'}
    task.save

    Task.find(task.id).extras['test'].should eq 'test value'
  end

  it 'should persist the owner.storage.id' do
    task = FactoryGirl.create :task
    task.storage_id.should eq task.owner.storage.id
  end

end

