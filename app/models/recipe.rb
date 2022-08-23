class Recipe < ApplicationRecord
  serialize :ingredients,Array

  has_many :meals
  has_many :meal_categories, through: :meals
end