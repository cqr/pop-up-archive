class CreateSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :subscription_plans do |t|
      t.integer :pop_up_hours

      t.timestamps
    end
  end
end
