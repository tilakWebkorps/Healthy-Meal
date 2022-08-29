# frozen_string_literal: true

class MealCategory < ApplicationRecord
  has_many :meals
  has_many :recipes
end
