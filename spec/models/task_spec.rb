require 'spec_helper'

describe Task do
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
end

