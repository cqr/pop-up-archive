class AddInitialPlans < ActiveRecord::Migration
  def up
    SubscriptionPlan.create(pop_up_hours: 100, amount: 1200, name: 'Small')
    SubscriptionPlan.create(pop_up_hours: 250, amount: 2500, name: 'Medium')
    SubscriptionPlan.create(pop_up_hours: 500, amount: 5000, name: 'Large')
  end

  def down
    SubscriptionPlan.find_each {|x| x.destroy }
  end
end
