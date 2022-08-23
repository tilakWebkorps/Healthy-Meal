class CreateMeals < ActiveRecord::Migration[6.1]
  def change
    create_table :meals do |t|
      t.integer :day_id
      t.integer :meal_category_id
      t.integer :recipe_id

      t.timestamps
    end
  end
end
