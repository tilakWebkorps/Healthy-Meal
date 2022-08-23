class CreateDays < ActiveRecord::Migration[6.1]
  def change
    create_table :days do |t|
      t.integer :for_day
      t.integer :plan_id

      t.timestamps
    end
  end
end
