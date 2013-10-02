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

  it 'should return type_name' do
    task = FactoryGirl.create :task
    task.type_name.should eq 'task'

    class Tasks::GoodTestTask < Task; end;
    Tasks::GoodTestTask.new.type_name.should eq 'good_test'
  end

end

