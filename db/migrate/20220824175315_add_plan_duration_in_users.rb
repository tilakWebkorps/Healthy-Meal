class AddPlanDurationInUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :plan_duration, :integer, default: 0
    add_column :users, :expiry_date, :datetime, default: nil
  end
end
