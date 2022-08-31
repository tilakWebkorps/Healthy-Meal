class AddForAgeInPlan < ActiveRecord::Migration[6.1]
  def change
    add_column :plans, :age_category_id, :integer
  end
end
