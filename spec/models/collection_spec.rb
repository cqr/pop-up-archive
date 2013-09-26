require 'spec_helper'

describe Collection do

  it "should be valid with default attributes" do
    @collection = FactoryGirl.build :collection
    @collection.save.should be_true
  end

end
