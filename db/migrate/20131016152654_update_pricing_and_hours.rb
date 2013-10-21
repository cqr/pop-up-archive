class UpdatePricingAndHours < ActiveRecord::Migration
  def up
    add_column :subscription_plans, :grandfathered, :boolean
    SubscriptionPlan.where(pop_up_hours: 100).first.update_attributes(pop_up_hours: 35, amount: 1500)
    SubscriptionPlan.where(pop_up_hours: 250).first.update_attributes(pop_up_hours: 100, amount: 4000)
    SubscriptionPlan.where(pop_up_hours: 500).first.update_attributes(pop_up_hours: 250, amount: 10000)
  end
end
