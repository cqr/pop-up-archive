require 'spec_helper'

describe Tasks::UploadTask do
  it "should set defaults" do
    task = Tasks::UploadTask.new(extras: {user_id: 1, filename: 'test.wav', filesize: 10000, last_modified: '12345'})
    task.should be_valid
    task.identifier.should eq('eb3f9ccf1ddb6e442c71a614b3f8fe8af705f56a')
    task.extras.should have_key 'chunks_uploaded'
  end

  it "should get chunks_uploaded as array" do
    task = Tasks::UploadTask.new
    task.chunks_uploaded.should eq []
    task.extras['chunks_uploaded'] = "1,2,3"
    task.chunks_uploaded.should eq [1,2,3]
  end

  it "should set chunks_uploaded as array" do
    task = Tasks::UploadTask.new
    task.chunks_uploaded = [1,2,3]
    task.extras['chunks_uploaded'].should eq "1,2,3\n"
    task.chunks_uploaded.should eq [1,2,3]
  end

  it "should mark completed on update" do
    task = Tasks::UploadTask.new(extras: {num_chunks: 2, chunks_uploaded:"1\n", key: 'this/is/a/key.mp3'})
    task.save!
    task.should be_created
    task.run_callbacks(:commit)
    task.add_chunk!('2')
    task.run_callbacks(:commit)
    task.should be_complete
  end

end

