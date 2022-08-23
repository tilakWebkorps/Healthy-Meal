class Meal < ApplicationRecord
  belongs_to :day
  belongs_to :meal_category
  belongs_to :recipe
end
