require 'spec_helper'

describe Instance do

  it "should allow create with valid attributes" do
    instance = Instance.new
    instance.digital = true
    instance.format = 'audio/wav'
    instance.location = 'http://this.is.an.example.com'
    instance.identifier = 'http://this.is.an.example.com'
    instance.save.should be_true
  end

end
