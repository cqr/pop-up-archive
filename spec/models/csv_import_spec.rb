require 'spec_helper'

describe CsvImport do
  it "should trigger processing of itself on create" do
    import = FactoryGirl.build :csv_import
    import.should_receive(:enqueue_processing)
    import.save
  end

end
