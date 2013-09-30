require 'spec_helper'

describe Entity do
  before { StripeMock.start }
  after { StripeMock.stop }

  subject { FactoryGirl.build :entity }
  let(:confirmed_entity) { FactoryGirl.create :entity, is_confirmed: true }
  let(:unconfirmed_entity) { FactoryGirl.create :entity }
  let(:middle_scoring_entity) { FactoryGirl.create :mid_entity }
  let(:high_scoring_entity) { FactoryGirl.create :high_entity }
  let(:low_scoring_entity) { FactoryGirl.create :low_entity }

  it { should be_valid }

  describe 'scope' do
    subject { Entity }
    its(:confirmed) { should include confirmed_entity }
    its(:confirmed) { should_not include unconfirmed_entity}

    its(:unconfirmed) { should include unconfirmed_entity }
    its(:unconfirmed) { should_not include confirmed_entity }

    its(:high_scoring) { should include high_scoring_entity }
    its(:high_scoring) { should_not include confirmed_entity }
    its(:high_scoring) { should_not include middle_scoring_entity }
    its(:high_scoring) { should_not include low_scoring_entity }
    its(:high_scoring) { should_not include unconfirmed_entity }

    its(:middle_scoring) { should include middle_scoring_entity }
    its(:middle_scoring) { should_not include confirmed_entity }
    its(:middle_scoring) { should_not include low_scoring_entity }
    its(:middle_scoring) { should_not include high_scoring_entity }
    its(:middle_scoring) { should_not include unconfirmed_entity }

    its(:low_scoring) { should_not include confirmed_entity }
    its(:low_scoring) { should_not include high_scoring_entity }
    its(:low_scoring) { should_not include middle_scoring_entity }
    its(:low_scoring) { should include unconfirmed_entity }
  end
end
