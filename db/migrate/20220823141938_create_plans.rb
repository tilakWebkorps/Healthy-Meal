class CreatePlans < ActiveRecord::Migration[6.1]
  def change
    create_table :plans do |t|
      t.string :name
      t.text :description
      t.integer :plan_duration
      t.integer :plan_cost

      t.timestamps
    end
  end
end
