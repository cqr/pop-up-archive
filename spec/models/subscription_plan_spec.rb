require 'spec_helper'

describe SubscriptionPlan do

  let(:plan) { FactoryGirl.create(:subscription_plan) }
  after(:each) { plan.destroy }

  it 'has a stripe plan' do
    plan.stripe_plan.should be_a Stripe::Plan
  end

  it 'mirrors the name to the stripe plan name' do
    plan.stripe_plan.name.should be plan.name
  end

  it 'allows setting the stripe plan name through the object' do
    plan.stripe_plan.name = 'dog'
    plan.name = 'cat'
    plan.stripe_plan.name.should eq 'cat'
  end

  it 'mirrors the amount to stripe' do
    plan.stripe_plan.amount.should be plan.amount
  end

  it 'sets the amount on stripe when set on the object' do
    plan.amount = 100
    plan.stripe_plan.amount.should be 100
  end

  it 'saves the stripe plan when the object itself is saved' do
    plan.name = 'chunk'
    plan.save
    plan.stripe_plan.should_receive(:save).and_call_original
    plan.save
  end

  it 'fails to save when the stripe plan fails to save' do
    plan.stripe_plan.interval = 'ducks'
    plan.save.should be false
  end

  it 'persists the stripe id' do
    stripe_id = plan.stripe_plan_id
    SubscriptionPlan.find(plan.id).stripe_plan_id.should eq stripe_id
  end

  it 'persists the amount' do
    plan.name = "Groald"
    plan.amount = 2000
    plan.save
    SubscriptionPlan.find(plan.id).amount.should eq 2000
  end

end
