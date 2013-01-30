require 'spec_helper'

describe CsvImport do
  let(:import) { FactoryGirl.build :csv_import }

  it "should trigger processing of itself on create" do
    import.should_receive(:enqueue_processing)
    import.save
  end

  it "should start in the new state" do
    import.state.should eq "new"
  end

  it "should transition to the queued state on create" do
    import.save
    import.state.should eq "queued"
  end

  it "should transition to the analyzed state after it is analyzed" do
    import.save
    import.analyze!
    import.state.should eq "analyzed"
  end

  it "should not permit analyzing unless it is saved" do
    expect(-> { import.analyze! }).to raise_exception
  end
end
