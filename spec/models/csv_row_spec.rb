require 'spec_helper'

describe CsvRow do
	let(:new_row) { FactoryGirl.build :csv_row }

  it "should save values as an array" do
    words = %w(a bunch of words)
    new_row.values = words
    new_row.save
    CsvRow.find(new_row.id).values.should eq words
  end
end
