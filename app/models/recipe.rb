class Recipe < ApplicationRecord
  serialize :ingredients,Array

  has_many :meals
  has_many :meal_categories, through: :meals

  validates :name, presence: true
  validates :description, presence: true
  validates :ingredients, :presence: true
end