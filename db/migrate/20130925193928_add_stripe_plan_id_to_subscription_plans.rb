class AddStripePlanIdToSubscriptionPlans < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :stripe_plan_id, :string
  end
end
